import pandas as pd
from pathlib import import Path

def parse_biosample(biosample):

    fields = {}

    with biosample.open('r') as f:
        for line in f:
            l = line.strip()

            if l.startswith('/'):
                k, v = l.lstrip('/').split('=')

                fields[k] = v

    return fields

records = {}

biosample_dir = snakemake.input[0]

for biosample in biosample_dir.glob('*.biosample'):

    sra = biosample.stem

    records[sra] = parse_biosample(biosample)

df = pd.DataFrame(records).T

df.to_csv(snakemake.output[0])
