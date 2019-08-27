import os

path = '/mnt/ris-fas1a/linux_groups2/baillie_grp/genomicc/Pilot_B_2019/5_analysis/20190507_trim_align_qc/genomicc_bamfiles'

neg_files = []

dirs = os.listdir(path)
for infile in dirs:
    if 'negative.ctss' in infile:
    	neg_files.append(infile)


for infile in neg_files:

	outfile = infile.replace('_negative', '.final')
	o = open(outfile, 'w')

	with open(infile, 'r') as inF:
		for line in inF:
			linea = (line.strip()).split('\t')
			outlist = [linea[0], linea[1], '-', linea[2]]
			output = '\t'.join(outlist)
			o.write(output + '\n')

	infile2 = infile.replace('_negative', '_positive')
	with open(infile2, 'r') as inF:
		for line in inF:
			linea = (line.strip()).split('\t')
			outlist = [linea[0], linea[1], '+', linea[2]]
			output = '\t'.join(outlist)
			o.write(output + '\n')
