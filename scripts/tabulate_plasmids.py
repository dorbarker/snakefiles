import argparse
import pandas as pd
from pathlib import Path
import collections


def arguments():

    parser = argparse.ArgumentParser()

    parser.add_argument('parent',
                        type=Path,
                        help='Parent directory containing directories for each strain')
    parser.add_argument('outdir',
                        type=Path,
                        help='Output directory')

    args = parser.parse_args()

    if not args.parent.exists():
        raise IOError('Input directory does not exist')

    if not args.outdir.exists():
        args.outdir.mkdir()

    return args


def main():

    args = arguments()

    joined_table = join_plasmid_typer_reports(args.parent)

    counted_plasmids = count_plasmids(joined_table)

    joined_table.to_csv(args.outdir / 'plasmid_summary.txt', sep='\t')

    counted_plasmids.to_csv(args.outdir / 'plasmid_counts.txt', sep='\t')


def join_plasmid_typer_reports(strains_dir: Path) -> pd.DataFrame:

    def join_table(strain: Path) -> pd.DataFrame:

        reports = strain.glob('*_report.txt')

        tables = (pd.read_csv(report, sep='\t') for report in reports)

        joined_table = pd.concat(tables, ignore_index=True)

        headers = joined_table.columns

        joined_table['strain'] = strain.stem

        headers.insert(0, 'strain')

        joined_table.reindex(headers, axis=1)

        return joined_table

    strains = (p for p in strains_dir.glob('*') if p.is_dir())

    strain_tables = (join_table(strain) for strain in strains)

    master_table = pd.concat(strain_tables)

    return master_table


def count_plasmids(table: pd.DataFrame) -> pd.DataFrame:

    def most_common(rep):

        return collections.Counter(rep).most_common()[0][0]

    spec = {'file_id': 'count', 'gc': 'mean', 'rep_type(s)': most_common, 'PredictedMobility': most_common}

    return table.groupby('file_id').aggregate(spec)


if __name__ == '__main__':
    main()
