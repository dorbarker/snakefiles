from pathlib import Path

fastas = [fasta.stem for fasta in Path('genomes').glob('*.fasta')]

rule all:
	input: expand('plasmid_reconstructions/{name}/contig_report.txt', name=fastas)

rule mobinit:
	output:
		touch('.mob_init_databses')
	conda:
		'envs/mob-suite.yaml'
	shell:
		'mob_init'

rule mobrecon:
	input:
		rules.mobinit.output,
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
