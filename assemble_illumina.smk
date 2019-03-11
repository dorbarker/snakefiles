from pathlib import Path

samples = [p.name for p in Path('fastqs').glob('*')]

rule all:
	input:
		expand('genomes/{sample}.fasta', sample=samples)

rule assemble_illumina:
	input:
		'fastqs/{sample}'

	output:
		'assemblies/{sample}/contigs.fa'

	threads:
		8

	conda:
		'envs/shovill.yaml'

	shell:
		'shovill --R1 {input}/*_R1*.f*q* --R2 {input}/*_R2*.f*q* '
		'--outdir assemblies/{wildcards.sample} --ram 12 --cpus {threads} '
		'--force'

rule symlink_illumina:
	input:
		rules.assemble_illumina.output

	output:
		'genomes/{sample}.fasta'

	group:
		'fasta_symlink'

	shell:
		'ln -sr {input} {output}'
