import os

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
		unpack(match_sample_to_fq)

	output:
		'shovill_output/{sample}/contigs.fa'

	threads:
		8

	shell:
		"rmdir shovill_output/{wildcards.sample}; "
		"shovill --R1 {input.r1} --R2 {input.r2} "
		"--outdir shovill_output/{wildcards.sample} "
		"--trim --cpus {threads} "

rule symlink_genome:
	input:
		'shovill_output/{sample}/contigs.fa'

	output:
		'genomes/{sample}.fasta'

	shell:
		'ln -sr {input} {output}'


