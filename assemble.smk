import os
import shutil

include: 'illumina_reads.py'

def match_sample_to_fq(wildcards):
	fwd = os.path.join(config['fastqs'], samples[wildcards.sample]['fwd'])
	rev = os.path.join(config['fastqs'], samples[wildcards.sample]['rev'])

	return {'r1': fwd, 'r2': rev}

rule assemble_genomes:
	input:
		expand('genomes/{sample}.fasta', sample=list(samples.keys()))

rule assemble:
	input:
		fwd=temp(lambda wc: os.path.join(config['temp'], wc.sample, samples[wc.sample]['fwd'])),
		rev=temp(lambda wc: os.path.join(config['temp'], wc.sample, samples[wc.sample]['rev']))

	output:
		'{outdir}/{{sample}}/contigs.fa'.format(config['shovill_output'])

	threads:
		8

	shell:
		"rmdir shovill_output/{wildcards.sample}; "
		"shovill --R1 {input.r1} --R2 {input.r2} "
		"--outdir shovill_output/{wildcards.sample} "
		"--trim --cpus {threads} "

rule copy_reads:
	input:
		fwd=lambda wc: os.path.join(config['fastqs'], samples[wc.sample]['fwd']),
		rev=lambda wc: os.path.join(config['fastqs'], samples[wc.sample]['rev'])

	output:
		fwd=temp(lambda wc: os.path.join(config['temp'], wc.sample, samples[wc.sample]['fwd'])),
		rev=temp(lambda wc: os.path.join(config['temp'], wc.sample, samples[wc.sample]['rev']))

	run:
		for i, o in zip((input.fwd, input.rev), (output.fwd, output.rev)):
			link_device = os.stat(input.fwd, follow_symlinks=False).st_dev
			target_device = os.stat(input.rev, follow_symlinks=True).st_dev

			if link_device != target_device:
				shutil.copyfile(i, o)
			else:
				os.symlink(i, o)

rule symlink_genome:
	input:
		'shovill_output/{sample}/contigs.fa'

	output:
		'genomes/{sample}.fasta'

	shell:
		'ln -sr {input} {output}'


