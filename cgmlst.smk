from pathlib import Path

JSONDIR = 'jsons'
GENOMES = 'genomes'
ALLELES = 'alleles'
TEMPDIR = 'tmp'

MARKERSFILE = next(Path().glob('*.markers'))
TESTNAME = MARKERSFILE.stem

NAMES = [Path(fasta).stem for fasta in Path(GENOMES).glob('*.fasta')]

ruleorder: update > create_table

rule all:
	input:
		'calls.csv'	

rule mist:
	input:
		'genomes/{name}.fasta'
	output:
		'jsons/{name}.json'
	shell:
		'/home/dbarker/bin/mist_bin/MIST.exe -a {ALLELES} -T {TEMPDIR} -t {MARKERSFILE} -b -j {output} {input}'


rule update:
	input:
		expand('{JSONDIR}/{name}.json', JSONDIR=JSONDIR, name=NAMES)
	shell:
		'python update_definitions.py -j jsons/ -t {TESTNAME} -a {ALLELES}'

rule create_table:
	input:
		expand('{JSONDIR}/{name}.json', JSONDIR=JSONDIR, name=NAMES)
	output:
		'calls.csv'
	shell:
		'python json2csv.py -j jsons/ -t {TESTNAME} -o {output}'
rule clean:
	shell:
		'rm {TEMPDIR}/*'
