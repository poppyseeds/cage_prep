import os

path = '/mnt/ris-fas1a/linux_groups2/baillie_grp/genomicc/Pilot_B_2019/5_analysis/20190507_trim_align_qc/genomicc_bamfiles/'

files = []

dirs = os.listdir(path)
for infile in dirs:
    if '.ctss' in infile:
    	files.append(infile)

print files

for infile in files:
	if 'negative' in infile:
		direction = '-'
	else:
		direction = '+'

	outfile = (infile.split('.'))[0] + '.bed'
	o = open(outfile, 'w')

	with open(infile, 'r') as inF:


		i = 0
		for line in inF:
			i = i + 1
			linea = (line.strip()).split('\t')
			end = int(linea[1]) + 1
			outlist = [linea[0], linea[1], str(end), str(i), linea[2], direction]
			output = '\t'.join(outlist)
			o.write(output + '\n')
