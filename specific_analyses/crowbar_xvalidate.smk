from pathlib import Path

original_jsons = list(Path('jsons').glob('*.json'))

rule extract_pristine_calls:
	input:
		'calls.csv'
	output:
		'pristine.csv'

	run:
		import pandas as pd
		calls = pd.read_csv(input[0], sep=',', index_col=0, header=0)
		pristine = calls.loc[[not any(v < 1) for i, v in calls.iterrows()]]
		pristine.to_csv('pristine.csv', sep=',', header=True, index=True)

rule extract_pristine_samples:
	input:
		'pristine.csv'

	output:
		'pristine_samples.txt'

	shell:
		'awk -F , "(NR>1) {{print $1}}" < {input} > {output}'

rule create_sample_chunks:
	input:
		'pristine_samples.txt'

	output:
		[f'sample_chunks/sample_{n}.txt' for n in range(10)]

	shell:
		'split -n 10 '
		'--suffix-length=1 '
		'--numeric-suffixes=1 '
		'--additional_suffix.txt '
		'{input} '
		'sample_'

rule symlink_jsons:
	input:
		'sample_chunks/sample_{n}.txt'

	output:
		touch('experiment_{n}/.copied')

	run:
		strains = Path(input[0]).read_text.split()
		for strain in strains:
			j = Path(strain).with_suffix('.json')
			src = Path('jsons').joinpath(j)
			dst = Path('experiment_{wildcards.n}').joinpath(j)
			dst.symlink_to(src)
