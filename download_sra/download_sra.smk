localrules: all

import pandas as pd

__author__ = 'Dillon Barker <dillon.barker@canada.ca>'

def get_accessions_from_runinfo(runinfo_path):
	
	if isinstance(runinfo_path, bytes):
		path = runinfo_path.decode()
	else:
		path = runinfo_path

	runinfo = pd.read_csv(path, sep=',', header=None)
	
	return list(runinfo.iloc[:, 0])

rule all:
	input:
		runinfo='{0}_runinfo.csv'.format(config['query']),
		assemblies=expand('genome_fastas/{accession}.fasta',
			accession=get_accessions_from_runinfo('{0}_runinfo.csv'.format(config['query'])))

rule download_runinfo:
	output:
		'{0}_runinfo.csv'.format(config['query'])
	shell:
		'esearch -query {config[query]} -db {config[db]} | '
		'elink -target sra | '
		'efetch -format runinfo | '
		'grep GENOMIC | '
		'grep -v METAGENOMIC > '
		'{output}'

rule assemble:
	input:
		fwd='fastqs/{accession}_1.fastq.gz',
		rev='fastqs/{accession}_2.fastq.gz'
	output:
		'assemblies/{accession}/contigs.fa'
	threads:
		8
	shell:
		'shovill --R1 {input.fwd} --R2 {input.rev} '
		'--outdir assemblies/{wildcards.accession} '
		'--cpus {threads} --ram 12 --force'

rule download_fastq:
	output:
		fwd='fastqs/{accession}_1.fastq',
		rev='fastqs/{accession}_2.fastq'
	threads:
		8
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
		'assemblies/{accession}/contigs.fa'
	output:
		'genome_fastas/{accession}.fasta'
	shell:
		'ln -sr {input} {output}'
