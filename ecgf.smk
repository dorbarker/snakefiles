from pathlib import Path

fastas = Path('genomes').glob('*.fasta')
cgf = Path('cgf')

rule all:
	input:
		[cgf.joinpath(p.name).with_suffix('.csv') for p in fastas]
 
rule ecgf:
	input:
		'genomes/{sample}.fasta'

	output:
		'cgf/{sample}.csv'
	
	conda:
		'envs/ecgf.yaml'
	
	threads:
		1

	shell:
		'eCGF {input} {output}'		
