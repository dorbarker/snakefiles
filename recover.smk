from pathlib import Path

samples = [p.stem for p in Path('genomes').glob('*.*')]

rule all:
	input:
		expand('recovered/{sample}.csv', sample=samples),
		expand('recovered/{sample}.json', sample=samples)


rule recover:
	input:
		'jsons/{sample}.json'

	output:
		'recovered/{sample}.csv',
		'recovered/{sample}.json'

	threads: 1

	shell:
		'crowbar recover --input {input} -o recovered --model model'

