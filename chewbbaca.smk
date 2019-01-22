from pathlib import Path

rule all:
	input:
		expand('cgmlst_{presence}/cgMLST.tsv', presence=(0.95, 0.999, 1.00))

rule define_wgmlst:
	input:
		list(Path('genomes').glob('*.fasta'))

	output:
		directory('wgmlst_schema')

	params:
		training_file=config['training']

	threads:
		32

	conda:
		'envs/chewbbaca.yaml'

	shell:
		'chewie CreateSchema -i genomes/ -o {output} '
		'--cpu {threads} --ptf {params.training_file}'

rule allele_call:
	input:
		rules.define_wgmlst.output

	output:
		directory('allele_call')

	params:
		training_file=config['training']

	threads:
		32

	conda:
		'envs/chewbbaca.yaml'

	shell:
		'chewie AlleleCall -i genomes/ -g {input} -o {output} '
		'--cpu {threads} --ptf {params.training_file}'

rule evaluate_schema:
	input:
		Path(rules.allele_call.output) / 'results_Alleles.txt'

	output:
		directory('allele_call_evaluation')

	conda:
		'envs/chewbbaca.yaml'

	shell:
		'chewie TestGenomeQuality -i {input} -o {output} -n 24 -t 500 -s 5'


rule extract_cgmlst:
	input:
		'allele_call_{date}/results_alleles.tsv'

	output:
		'cgmlst_{presence}/cgMLST.tsv'

	conda:
		'envs/chewbbaca.yaml'

	shell:
		'chewie -i {input} -o cgmlst_{presence} -p {presence}'


