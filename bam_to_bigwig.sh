#! /usr/bin/env bash

#module add apps/gcc/samtools/1.6
#module add apps/gcc/BEDTools/2.25.0

# get input files
tags=(CON0004 CON0006 CON0007 CON0008 CON0009 CON0010 CON0011 CON0015 CON0017 CON0018 CON0020 CON0023 CON0026 GEN0001 GEN0008 GEN0013 GEN0017 GEN0018 GEN0019 GEN0020 GEN0071 GEN0111 GEN0201 GEN0207)


for tag in "${tags[@]}" ; do
	for FILE in `find ./ -type f -name "$tag.bam"` ; do
# name output files
		echo ------
		#get basic name
		a=${FILE##*/}
		bam=${a%.bam}
		#name bams
		sorted=$bam.sorted.bam
		filtered=$bam.filtered.bam
		#name ctss files
		positive=$bam.positive.ctss
		negative=$bam.negative.ctss
# do thing

		# SORT AND FILTER - very quick 
		samtools sort $FILE -o $sorted
		echo SORTED
		samtools view -b -F 0x04 -q 1 -o $filtered $sorted
		echo FILTERED

		# CREATE COUNT FILES - Takes a few (3-4) hours per file
		bedtools genomecov -ibam $filtered -d -strand - | awk '$3 != 0' > $negative
		bedtools genomecov -ibam $filtered -d -strand + | awk '$3 != 0' > $positive
	done
done

python collate_ctss_files.py
python create_bed_file_for_genomicc_bamfiles.py

for tag in "${tags[@]}" ; do
   echo $tag
   for FILE in `find ./ -type f -name "$tag*"` ; do
   	echo $FILE
    a=${FILE##*/}
    bed=${a%.bed}

	bedgraph=$bed.bedgraph
	sorted=$bed.sorted.bedgraph
	bigwig=$bed.bw

	echo 'Here Now'
	 
	awk '{printf "%s\t%d\t%d\t%2.3f\n" , $1,$2,$3,$5}' $FILE > $bedgraph
	sort -k1,1 -k2,2n $bedgraph > $sorted
	bedGraphToBigWig $sorted hg38.chrom.sizes $bigwig
	 
	done
done

