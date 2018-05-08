import re
import os

include: 'cgmlst.smk'
include: 'assemble.smk'

fastq_dir = 'fastqs'

fastq_files = sorted(os.listdir(fastq_dir))

match_illumina = '(.+?)(_S\d+_L001)?_(R[12])(_001)?\.f(ast)?q\.?(gz)?'
sample_pattern = re.compile(match_illumina)

genome_samples = [re.sub(sample_pattern, '\\1', f)
				  for i, f in enumerate(fastq_files)
				  if i % 2 is 0]

# master rule
rule analyze:
	input:
		'pristine.csv',
		'cgf_prediction.csv',
		'pristine_distance_matrix.csv',
		'missing_data_histogram.png'

rule ecgf:
	input:
		expand('genomes/{sample}.fasta', sample=genome_samples)

	output:
		'cgf_prediction.csv'

	shell:
		"eCGF genomes {output}"

rule distance_matrix:
	input:
		'calls.csv'

	output:
		'calls_distance_matrix.csv'

	script:
		'scripts/hamming_distance_matrix.py'

rule pristine_distance_matrix:
	input:
		'pristine.csv',
		'calls_distance_matrix.csv'

	output:
		'pristine_distance_matrix.csv'

	run:
		import pandas as pd
		pristine_genomes = pd.read_csv(input[0], header=0, index_col=0).index
		calls_dm = pd.read_csv(input[1], header=0, index_col=0)
		pristine_dm = calls_dm.loc[pristine_genomes, pristine_genomes]
		pristine_dm.to_csv(output[0])

rule missing_data_histogram:
	input:
		'calls.csv'

	output:
		'missing_data_histogram.png'

	script:
		'scripts/missing_data_histogram.R'
