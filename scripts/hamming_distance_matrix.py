import numpy as np
import pandas as pd

calls = pd.read_csv(snakemake.input[0], header=0, index_col=0)

n_genomes = len(calls)

dm = np.matrix(np.zeros((n_genomes, n_genomes)))

for i, genome1 in enumerate(calls.index): # calls.iterrows isn't appropriate
    for j, genome2 in enumerate(calls.index):

        if j <= i or i == n_genomes:
            continue

        genes1 = calls.loc[genome1]
        genes2 = calls.loc[genome2]

        selected = (genes1 > 0) & (genes2 > 0)

        selected_genes1 = genes1[selected]
        selected_genes2 = genes2[selected]

        distance = np.count_nonzero(selected_genes1 != selected_genes2)

        dm[i,j] = dm[j,i] = distance

distance_matrix = pd.DataFrame(dm, index=calls.index, columns=calls.index)

distance_matrix.to_csv(snakemake.output[0])