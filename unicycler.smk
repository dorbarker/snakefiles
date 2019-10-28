from pathlib import Path

samples = [x.stem for x in Path('fastqs').glob('*')]

rule all:
	input:
		expand('genomes/{sample}.fasta', sample=samples)

rule unicycler:
	input:
		'fastqs/{sample}'

	output:
		'assemblies/{sample}/assembly.fasta'

	threads:
		8

	shell:
		'fwd_rev=({input}/*); '
		'unicycler -1 ${{fwd_rev[0]}} -2 ${{fwd_rev[1]}} --threads {threads} -o {output}'

rule symlink_genomes:
	input:
		'assemblies/{sample}/assembly.fasta'

	output:
		'genomes/{sample}.fasta'

	group:
		'symlink'

	threads:
		1

	shell:
		'ln -sr {input} {output}'
