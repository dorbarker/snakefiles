from pathlib import Path
import os.path

NAMES = [Path(fasta).stem for fasta in Path('genomes/').glob('*.fasta')]

ruleorder: update > create_table

rule cgmlst:
	input:
		'pristine.csv'

rule call:
	input:
		'genomes/{name}.fasta'

	output:
		'jsons/{name}.json'

	threads:
		1

	shell:
		'fsac call -a {config[alleles]} -i {input} -o {output}'

rule update:
	input:
		expand('jsons/{name}.json', name=NAMES)


	output:
		touch('.updated')

	shell:
		'fsac update -a {config[alleles]} -j jsons/'

rule create_table:
	input:
		expand('jsons/{name}.json', name=NAMES),
		'.updated'

	output:
		'calls.csv'

	shell:
		'fsac tabulate -j jsons/ -o {output} -d ,'


rule create_pristine:
	input:
		'calls.csv'
	output:
		'pristine.csv'
	run:
		import pandas as pd
		calls = pd.read_csv(input[0], sep=',', index_col=0, header=0)
		pristine = calls.loc[[not any(v < 1) for i, v in calls.iterrows()]]
		pristine.to_csv('pristine.csv', sep=',', header=True, index=True)

rule clean:
	shell:
		'rm {TEMPDIR}/*'
