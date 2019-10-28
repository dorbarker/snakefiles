from pathlib import Path

samples = [fasta.stem for fasta in Path('genomes').glob('*.fasta')]

rule all:
	input:
		expand('annotations/{sample}/{sample}.gff', sample=samples)

rule annotate:
	input:
		'genomes/{sample}.fasta'
	output:
		'annotations/{sample}/{sample}.gff'
	conda:
		'envs/prokka.yaml'
	threads:
		8

	shell:
		'prokka '
		'--force '
		'--cpus 8 '
		'--centre NML '
		'--compliant '
		'--outdir annotations/{wildcards.sample} '
		'--prefix {wildcards.sample} '
		'{input}'
