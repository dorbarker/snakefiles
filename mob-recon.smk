from pathlib import Path

rule all:
	input: expand('plasmid_reconstructions/{name}/contig_report.txt',
				  name=[fasta.stem for fasta in Path('.').glob('*.fasta'))

rule mobrecon:
	input:
		'{name}.fasta'

	params:
		outdir='plasmid_reconstructions/{name}'

	output:
		'{params.outdir}/contig_report.txt'

	conda:
		'envs/mob-suite.yaml'

	threads:
		32

	shell:
		'mob_recon -n {threads} -i {input} -o {params.outdir}'
