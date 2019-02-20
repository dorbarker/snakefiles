rule assemble_illumina:
	input:
		'fastqs/{sample}'

	output:
		'assemblies/{sample}/contigs.fa'

	threads:
		8

	conda:
		'envs/shovill.yaml'

	shell:
		'shovill --R1 {input}/*_R1*.f*q* --R2 {input}/*_R2*.f*q* '
		'--outdir assemblies{wildcards.sample} --ram 12 --cpus {threads} '
		'--force'
