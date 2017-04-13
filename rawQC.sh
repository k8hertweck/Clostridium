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
ls raw/*.gz | sed s/_R[12]_001.fastq.gz// | sed s/raw.// | uniq > $SCRIPTS/ClostridiumStrains.lst
# set up directory
mkdir trim
# loop across all strains
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		# quality trimming 
		java -jar $TRIM/trimmomatic-0.36.jar PE -threads 4 -phred33 \
			$DATA/raw/"$x"_R1_001.fastq.gz $DATA/raw/"$x"_R2_001.fastq.gz \
			$DATA/trim/"$x"_1paired.fq.gz $DATA/trim/"$x"_1unpaired.fq.gz \
			$DATA/trim/"$x"_2paired.fq.gz $DATA/trim/"$x"_2unpaired.fq.gz \
			ILLUMINACLIP:$TRIM/adapters/NexteraPE-PE.fa:2:30:10 \
			SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3  HEADCROP:8 MINLEN:50
done

# reassess trimmed files
cd trim
fastqc *_1paired.fq.gz *_2paired.fq.gz
