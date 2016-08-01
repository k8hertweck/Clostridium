#!/bin/bash

## quality control of raw sequence data prior to assembly 
## usage:
#	rawQC.sh PATH/TO/DATA
## dependencies:
#	fastqc
#	trimmomatic

TRIM=/Applications/Trimmomatic-0.36
DATA=$1
SCRIPTS=`pwd`

cd $DATA

## QC of raw files
fastqc *.fastq.gz
mkdir raw
mv *zip *html *gz raw

## quality trimming and filtering
# make list of files
ls raw/*.gz | sed s/_R[12]_001.fastq.gz// | sed s/raw.// | uniq > $SCRIPTS/ClostridiumFiles.lst
# set up directory
mkdir trim
# loop trimmomatic across all strains
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		# quality trimming 
		java -jar $TRIM/trimmomatic-0.36.jar PE -threads 4 -phred33 \
			$DATA/raw/"$x"_R1_001.fastq.gz $DATA/raw/"$x"_R2_001.fastq.gz \
			$DATA/trim/"$x"_1paired.fq.gz $DATA/trim/"$x"_1unpaired.fq.gz \
			$DATA/trim/"$x"_2paired.fq.gz $DATA/trim/"$x"_2unpaired.fq.gz \
			ILLUMINACLIP:$TRIM/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 LEADING:15 TRAILING:15  MINLEN:50
done

# make list of strains
sed s/_S._L00[1234]// $SCRIPTS/ClostridiumFiles.lst > $SCRIPTS/ClostridiumStrains.lst
# concatenate data from each strain
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		cat "$x"*1paired.fq.gz > "$x"_R1.fq.gz
		cat "$x"*2paired.fq.gz > "$x"_R2.fq.gz
done

# reassess trimmed files
cd trim
fastqc *_R1.fq.gz *_R2.fq.gz
