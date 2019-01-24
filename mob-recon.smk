from pathlib import Path

fastas = [fasta.stem for fasta in Path('genomes').glob('*.fasta')]

rule all:
	input: expand('plasmid_reconstructions/{name}/.mob_typer', name=fastas)

rule mobinit:
	output:
		touch('.mob_init_databses')
	conda:
		'envs/mob-suite.yaml'
	shell:
		'mob_init'

rule mobrecon:
	input:
		db=rules.mobinit.output,
		genome='genomes/{name}.fasta'

	params:
		outdir='plasmid_reconstructions/{name}'

	output:
		'plasmid_reconstructions/{name}/contig_report.txt'

	conda:
		'envs/mob-suite.yaml'

	threads:
		8	

	shell:
		'mob_recon -n {threads} -i {input.genome} -o {params.outdir}'

rule mobtyper:
	input:
		'plasmid_reconstructions/{name}/contig_report.txt'
	
	output:
		touch('plasmid_reconstructions/{name}/.mob_typer')

	conda:
		'envs/mob-suite.yaml'
	
	threads:
		8

	shell:
		'for i in plasmid_reconstructions/{wildcards.name}/plasmid_*.fasta; do '
		'    mob_typer -n {threads} --infile $i --outdir plasmid_reconstructions/{wildcards.name}; '
                'done'
