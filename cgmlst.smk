from pathlib import Path
import os.path

JSONDIR = 'jsons'
GENOMES = 'genomes'
ALLELES = 'alleles'
TEMPDIR = 'tmp'

MARKERSFILE = next(Path().glob('*.markers'))
TESTNAME = MARKERSFILE.stem

NAMES = [Path(fasta).stem for fasta in Path(GENOMES).glob('*.fasta')]

ruleorder: update > create_table

rule cgmlst:
	input:
		'pristine.csv'

rule mist:
	input:
		'genomes/{name}.fasta'

	output:
		'jsons/{name}.json'

	threads:
		1

	shell:
		"/home/dbarker/bin/mist_bin/MIST.exe "
		"-a {ALLELES} -T {TEMPDIR} -t {MARKERSFILE} -b -j {output} {input}"


rule update:
	input:
		expand('{JSONDIR}/{name}.json', JSONDIR=JSONDIR, name=NAMES)
	output:
		touch('.updated')
	shell:
		"python {workflow.basedir}/update_definitions.py "
		"-j jsons/ -t {TESTNAME} -a {ALLELES}"

rule create_table:
	input:
		expand('{JSONDIR}/{name}.json', JSONDIR=JSONDIR, name=NAMES),
		'.updated'
	output:
		'calls.csv'
	shell:
		'python {workflow.basedir}/json2csv.py -j jsons/ -t {TESTNAME} -o {output}'

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
