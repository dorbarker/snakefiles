__author__ = 'Dillon Barker <dillon.barker@canada.ca>'

elink_cmd = 'elink -target sra | ' if config['db'] != 'sra' else ''

rule all:
	input:
		runinfo='{0}_runinfo.csv'.format(config['query']),
		assemblies=dynamic('genomes/{accession}.fasta'),
		metadata='metadata.tsv'

rule download_runinfo:
	output:
		'{0}_runinfo.csv'.format(config['query'])
	
	conda:
		'envs/entrez-direct.yaml'

	shell:
		'''
		esearch -query {{config[query]}} -db {{config[db]}} | {}
		efetch -format runinfo |
		grep GENOMIC |
		grep -v METAGENOMIC |
		grep {{config[filter_by]}} >
        	{{output}}
		'''.format(elink_cmd).replace('\n', '')

rule get_accessions:
	input:
		rules.download_runinfo.output

	output:
		dynamic('accessions/{acc}')

	run:
		import pandas as pd
		from pathlib import Path
		accessions = Path('accessions/')

		runinfo = pd.read_csv(input[0], sep=',', header=None)
		
		for acc in runinfo.iloc[:, 0]:
			
			try:
				dummy = accessions / Path(acc)
				dummy.touch(exist_ok=False)
			
			except FileExistsError:
				continue

rule assemble:
	input:
		fwd='fastqs/{accession}_1.fastq.gz',
		rev='fastqs/{accession}_2.fastq.gz'

	output:
		'assemblies/{accession}/contigs.fa'

	conda:
		'envs/shovill.yaml'

	threads:
		8

	shell:
		'shovill --R1 {input.fwd} --R2 {input.rev} '
		'--outdir assemblies/{wildcards.accession} '
		'--cpus {threads} --ram 12 --force'

rule download_fastq:
	input:
		'accessions/{accession}'

	output:
		fwd='fastqs/{accession}_1.fastq',
		rev='fastqs/{accession}_2.fastq'

	threads:
		8

	conda:
		'envs/sra-tools.yaml'

	shell:
		'fasterq-dump -O fastqs --mem 500MB --threads {threads} '
		'{wildcards.accession}'

rule compress_fastq:
	input:
		fwd='fastqs/{accession}_1.fastq',
		rev='fastqs/{accession}_2.fastq'
	output:
		fwd='fastqs/{accession}_1.fastq.gz',
		rev='fastqs/{accession}_2.fastq.gz'
	shell:
		'gzip {input.fwd} {input.rev}'

rule symlink_genome:
	input:
		rules.assemble.output
	output:
		'genomes/{accession}.fasta'

	group:
		'symlinks'

	shell:
		'ln -sr {input} {output}'

rule download_biosample:
	input:
		rules.symlink_genome.output

	output:
		'biosamples/{accession}.biosample'

	group:
		'biosamples'

	conda:
		'envs/entrez-direct.yaml'

	shell:
		'esearch -db sra -query {wildcards.accession} | '
		'elink -target biosample | '
		'efetch > {output}'

rule tabulate_biosamples:
	input:
		biosamples=dynamic('biosamples/{acc}.biosample')

	output:
		'metadata.tsv'

	shell:
		'awk -f scripts/biosample_to_long.awk {input} > {output}'
