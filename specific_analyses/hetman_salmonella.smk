import os
import re

configfile: 'hetman_salmonella.yaml'

include: 'assemble.smk'

fastq_files= sorted(os.listdir(config['fastqs']))

match_illumina = '(.+?)(_S\d+_L001)?_(R[12])(_001)?\.f(ast)?q\.?(gz)?'
sample_pattern = re.compile(match_illumina)

fwds, revs = zip(*(fastq_files[i:i+2] for i in range(0, len(fastq_files), 2)))

sample_names = [re.sub(sample_pattern, '\\1', f) for f in fwds]

samples = {sample: {'fwd': fwd, 'rev': rev}
		   for sample, fwd, rev
		   in zip(sample_names, fwds, revs)}


mlst_out_template = '{mlst_out}/{{scheme}}/{{sample}}.mlst'.format(
													config['mentalist_outdir']
													)

rule salmy:
	input:
		expand(mlst_out_template,
			   scheme=['cgmlst','wgmlst'], sample=sample_names),

		expand('genomes/{sample}.fasta', sample=sample_names),
		'.snvphyl'

rule snvphyl:
	input:
		ref=config['reference'],
		fqs=config['fastqs'],

	output:
		config['snvphyl_outdir'],
		touch('.snvphyl')

	shell:
		"snvphyl.py --reference-file {input.ref} --fastq-dir {input.fqs} "
		"--output {output}"

rule mentalist:
	input:
		fwd='{fastqs}/{fwd}'.format(fastqs=config['fastqs'],
									fwd=samples[wildcards.sample]['fwd']),

		rev='{fastqs}/{rev}'.format(fastqs=config['fastqs'],
									rev=samples[wildcards.sample]['rev']),

		db='{scheme}_alleles/{scheme}.db'

	output:
		mlst_out_template

	shell:
		"mentalist call -o {output} --output_special --db {input.db} "
		"-1 {input.fwd} -2 {input.rev}"

rule build_mentalist_db:
	input:
		[os.path.join('{scheme}_alleles/', fasta)
		 for fasta in os.listdir('{scheme}_alleles')]

	output:
		'{scheme}_alleles/{scheme}.db'

	params:
		kmer=config['kmer_size']

	threads:
		24

	shell:
		"mentalist build_db --threads {threads} -k {params.kmer} "
		"--db {output} --fasta_files {input}"
