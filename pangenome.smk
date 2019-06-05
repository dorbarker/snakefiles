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

	threads:
		8

	shell:
		'prokka '
		'--force '
		'--cpus 8 '
		'--outdir annotations/{wildcards.accession} '
		'--prefix {wildcards.accession} '
		'{input}'

rule pangenome:
	input:
		annotated

	output:
		'accessory_binary_genes.fa',
		'accessory_binary_genes.fa.newick',
		'accessory_graph.dot',
		'accessory.header.embl',
		'accessory.tab',
		'blast_identity_frequency.Rtab',
		'clustered_proteins',
		'core_accessory_graph.dot',
		'core_accessory.header.embl',
		'core_accessory.tab',
		'gene_presence_absence.csv',
		'gene_presence_absence.Rtab',
		'number_of_conserved_genes.Rtab',
		'number_of_genes_in_pan_genome.Rtab',
		'number_of_new_genes.Rtab',
		'number_of_unique_genes.Rtab',
		'summary_statistics.txt'
	conda:
		'envs/roary.yaml'
	
	threads:
		144

	shell:
		'find annotations/ -name "*.gff" -exec roary -p {threads} -cd 99.9 "{{}}" +'
		# 'roary '
		# '-p {threads} '
		# '-cd 99.9 '
		#'{input}'

rule tidy_pangenome:
	input:
		rules.pangenome.output
	output:
		'pangenome/gene_presence_absence.Rtab'
	params:
		directory='pangenome/'
	shell:
		'mv -t {params.directory} {input}'
