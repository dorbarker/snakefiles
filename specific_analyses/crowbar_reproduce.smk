configfile: 'crowbar_reproduce.yaml'

seeds = list(range(config['seeds']['min'], config['seeds']['max'] + 1))

monte_carlo_tests = [10, 35, 100, 350, 1000]
iteration_replicates = list(range(10))

rule all:
	input:
		'figures/genomes_success.png',
		expand('subset_output/{seed}.tsv', seed=seeds),
		expand('iteration_replicates/{mc}/{replicate}.tsv',
				mc=monte_carlo_tests, replicate=iteration_replicates),
		expand('tables/{mc}_results.tex', mc=monte_carlo_tests)

rule tabulate_iteration_replicates:
	input:
		'iteration_replicates/{mc}/'

	output:
		'tables/{mc}_results.tex'

	shell:
		"python3 scripts/tabulate_iteration_replicates.py "
		"--input-dir {input} --output {output}"

rule plot_genomes_success:
	input:
		allcalls=config['files']['calls'],
		subsets=expand('subset_output/{seed}.tsv', seed=seeds)

	output:
		'figures/genomes_success.png'

	shell:
		"python3 scripts/plot_genomes_success.py --all-calls {input.allcalls} "
		"--results-dir subset_output --output {output}"

rule generate_subset:
	input:
		config['files']['calls']

	output:
		'call_subsets/{seed}.csv'

	run:
		import random
		from pathlib import Path
		import pandas as pd

		calls = pd.read_csv(input[0], sep=',', index_col=0, header=0)

		seed = int(Path(output[0]).stem)

		random.seed(seed)

		size = random.randint(100, len(calls)-1)

		calls_subset = calls.sample(size, random_state=seed)

		calls_subset.to_csv(output[0], sep=',')

rule recover_subset:
	input:
		calls='call_subsets/{seed}.csv',
		dists='distances.csv'

	output:
		res='subset_output/{seed}.tsv',
		tmp=temp('tmp/{seed}/')

	params:
		trunc='--truncation-probability {}'.format(config['probs']['trunc']),
		missing='--missing-probability {}'.format(config['probs']['missing']),
		ref='--reference {}'.format(config['files']['reference']),
		reps='--replicates {}'.format(config['montecarlo']),

	shell:
		"python3 crowbar/test/simulate_recovery.py --cores {threads} "
		"{params.reps} {params.trunc} {params.missing} "
		"{params.ref} --tempdir {output.tmp} --seed {wildcards.seed} "
		"--distances {input.dists} "
		"--output {output.res} {input.calls} alleles jsons"

rule create_distance_matrix:
	input:
		config['files']['calls']

	output:
		'distances.csv'

	threads:
		99

	run:
		import pandas as pd
		from pathlib import Path
		from crowbar.shared import hamming_distance_matrix
		calls = pd.read_csv(input[0], sep=',', header=0, index_col=0)
		_ = hamming_distance_matrix(Path(output[0]), calls, threads)

rule recovery_replicates:
	input:
		calls=config['files']['calls'],
		dists='distances.csv'

	output:
		res='iteration_replicates/{mc}/{replicate}.tsv',
		tmp=temp('tmp/{mc}/{replicate}/')

	threads:
		99

	params:
		trunc='--truncation-probability {}'.format(config['probs']['trunc']),
		missing='--missing-probability {}'.format(config['probs']['missing']),
		ref='--reference {}'.format(config['files']['reference'])

	shell:
		"python3 crowbar/test/simulate_recovery.py --cores {threads} "
		"--replicates {wildcards.mc} {params.trunc} {params.missing} "
		"{params.ref} --tempdir {output.tmp} --seed {wildcards.replicate} "
		"--distances {input.dists} "
		"--output {output.res} {input.calls} alleles jsons"

