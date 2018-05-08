import re

fastq_files= sorted(os.listdir(config['fastqs']))

match_illumina = '(.+?)(_S\d+_L001)?_(R[12])(_001)?\.f(ast)?q\.?(gz)?'
sample_pattern = re.compile(match_illumina)

fwds, revs = zip(*(fastq_files[i:i+2] for i in range(0, len(fastq_files), 2)))

sample_names = [re.sub(sample_pattern, '\\1', f) for f in fwds]

samples = {sample: {'fwd': fwd, 'rev': rev}
		   for sample, fwd, rev
		   in zip(sample_names, fwds, revs)}
