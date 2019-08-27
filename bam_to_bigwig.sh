#! /usr/bin/env bash

#module add apps/gcc/samtools/1.6
#module add apps/gcc/BEDTools/2.25.0

# get input files
tags=(<sample_names>)


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

#!/bin/bash

##FROM MAZDAX SALAVATI
#refactor for efficiency

for f in ../input/*.bam;do

        BWNAME=$(basename -s .bam $f)

        echo $BWNAME

        bedtools genomecov -ibam $f -d -strand + | awk -v width=1 '!($1~/^NW/)&&($3!=0) {print $1,$2,$2+width,$3}' | sort -k1,1 -k2,2n --parallel=6 > ${BWNAME}.plus.bedGraph

        ./bedGraphToBigWig ${BWNAME}.plus.bedGraph ref_conv ${BWNAME}.plus.bw

        bedtools genomecov -ibam $f -d -strand - | awk -v width=1 '!($1~/^NW/)&&($3!=0) {print $1,$2,$2+width,$3}' | sort -k1,1 -k2,2n --parallel=6 > ${BWNAME}.minus.bedGraph

        ./bedGraphToBigWig ${BWNAME}.minus.bedGraph ref_conv ${BWNAME}.minus.bw

        echo "$BWNAME both files are done!"

done;