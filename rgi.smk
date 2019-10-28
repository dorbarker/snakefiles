from pathlib import Path

samples = [fasta.stem for fasta in Path('genomes').glob('*.fasta')]

rule all:
	input:
		expand('rgi_results/{sample}.{ext}',
			sample=samples,
			ext=('txt', 'json'))

rule rgi:
	input:
		'genomes/{sample}.fasta'
	output:
		'rgi_results/{sample}.txt',
		'rgi_results/{sample}.json'

	shell:
		'rgi main '
		'--input_sequence {input} '
		'--output_file rgi_results/{sample} '
		'--input_type contig '
		'--clean '
		'--local '
