import os
import shutil

include: 'illumina_reads.py'

def match_sample_to_fq(wildcards, path):

	prepend = path.format(sample=wildcards.sample)

	fwd = os.path.join(prepend, samples[wildcards.sample]['fwd'])
	rev = os.path.join(prepend, samples[wildcards.sample]['rev'])

	return {'r1': fwd, 'r2': rev}


rule assemble_genomes:
	input:
		expand('genomes/{sample}.fasta', sample=list(samples.keys()))

rule assemble:
	input:
		unpack(partial(match_sample_to_fq, path=os.path.join(config['fastqs'])))

	output:
		'{outdir}/{{sample}}/contigs.fa'.format(outdir=config['shovill_outdir'])

	message:
		'assemble {input} {output}'
	threads:
		4

	shell:
		"rmdir shovill_output/{wildcards.sample}; "
		"mkdir -p tmp/{wildcards.sample}/fastqs; "
		"rsync -L {input.r1} tmp/{wildcards.sample}/{input.r1}; "
		"rsync -L {input.r2} tmp/{wildcards.sample}/{input.r2}; "
		"shovill --R1 tmp/{wildcards.sample}/{input.r1} "
		"--R2 tmp/{wildcards.sample}/{input.r2} "
		"--outdir shovill_output/{wildcards.sample} "
		"--trim --cpus {threads}; "
		"rm -r tmp/{wildcards.sample} "


# rule copy_reads:
# 	input:
# 		unpack(partial(match_sample_to_fq,
# 					   path=os.path.join(config['fastqs'])))
# 	output:
# 		partial(match_sample_to_fq,
# 					   path=os.path.join(config['tmp'], '{sample}'))()
#
# 	message:
# 		'copy_reads {input} {output}'
# 	run:
# 		print(input, output)
# 		for i, o in zip((input.fwd, input.rev), (output.fwd, output.rev)):
# 			link_device = os.stat(input.fwd, follow_symlinks=False).st_dev
# 			target_device = os.stat(input.rev, follow_symlinks=True).st_dev
#
# 			if link_device != target_device:
# 				shutil.copyfile(i, o)
# 			else:
# 				os.symlink(i, o)

rule symlink_genome:
	input:
		'shovill_output/{sample}/contigs.fa'

	output:
		'genomes/{sample}.fasta'

	shell:
		'ln -sr {input} {output}'


