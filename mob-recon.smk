from pathlib import Path

fastas = [fasta.stem for fasta in Path('genomes').glob('*.fasta')]

rule all:
	input: expand('plasmid_reconstructions/{name}/contig_report.txt', name=fastas)

rule mobrecon:
	input:
		'genomes/{name}.fasta'

	params:
		outdir='plasmid_reconstructions/{name}'

	output:
		'plasmid_reconstructions/{name}/contig_report.txt'

	conda:
		'envs/mob-suite.yaml'

	threads:
		32

	shell:
		'mob_recon -n {threads} -i {input} -o {params.outdir}'
