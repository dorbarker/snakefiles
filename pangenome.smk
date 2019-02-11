from pathlib import Path

ruleorder: annotate > pangenome

def annotated(wildcards):

	pattern = 'annotations/{accession}/{accession}.gff'

	accessions = [p.stem for p in Path('genomes').glob('*.fasta')]

	return [pattern.format(accession=acc) for acc in accessions]

rule all:
	input:
		'pangenome/gene_presence_absence.Rtab'

rule annotate:
	input:
		'genomes/{accession}.fasta'

	output:
		'annotations/{accession}/{accession}.gff'

	conda:
		'envs/prokka.yaml'

	shell:
		'prokka '
		'--force '
		'--outdir annotations/{wildcards.accession} '
		'--prefix {wildcards.accession} '
		'{input}'

rule pangenome:
	input:
		annotated

	output:
		'pangenome/gene_presence_absence.Rtab'

	conda:
		'envs/roary.yaml'

	shell:
		'roary '
		'-f  pangenome '
		'-p {threads} '
		'-cd 99.9 '
		'{input}'
