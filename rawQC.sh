#!/bin/bash

## quality control of raw sequence data prior to assembly
## usage:
#	rawQC.sh PATH/TO/PROJECT
# 	PATH/TO/PROJECT is location of directory containing all fastq.gz files
# 	set TRIM to wherever Trimmomatic is installed
## dependencies:
#	fastqc (v0.11.7): quality control
#		(https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), installed and in path
#	trimmomatic (version 0.38): quality filtering and trimming
#		(http://www.usadellab.org/cms/?page=trimmomatic)

PROJECT=$1
FASTQC=/Applications/FastQC-0.11.7/fastqc
TRIM=/Applications/Trimmomatic-0.38
SCRIPTS=`pwd`

cd $PROJECT

## QC of raw files
echo "FASTQC ON RAW FILES"
#$FASTQC *.fastq.gz
mkdir raw
mv *zip *html *gz raw

## quality trimming and filtering
# make list of files
#ls raw/*.gz | sed s/_R[12]_001.fastq.gz// | sed s/raw.// | uniq > $SCRIPTS/ClostridiumFiles.lst
# make list of strains
#sed s/_S._L00[1234]// $SCRIPTS/ClostridiumFiles.lst > $SCRIPTS/ClostridiumStrains.lst
# set up directory
mkdir trim
# loop trimmomatic across all strains
echo "QUALITY TRIMMING"
for x in `cat $SCRIPTS/ClostridiumFiles.lst`
	do
		# quality trimming
		echo $x
		java -jar $TRIM/trimmomatic-0.38.jar PE -threads 4 -phred33 \
			$PROJECT/raw/"$x"_R1_001.fastq.gz $PROJECT/raw/"$x"_R2_001.fastq.gz \
			$PROJECT/trim/"$x"_1paired.fq.gz $PROJECT/trim/"$x"_1unpaired.fq.gz \
			$PROJECT/trim/"$x"_2paired.fq.gz $PROJECT/trim/"$x"_2unpaired.fq.gz \
			ILLUMINACLIP:$TRIM/adapters/NexteraPE-PE.fa:2:30:10 \
			SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3  HEADCROP:8 MINLEN:50
done

# reassess trimmed files
cd trim
echo "FASTQC ON TRIMMED FILES"
#$FASTQC *_1paired.fq.gz *_2paired.fq.gz

# concatenate read files
mkdir combined
echo "CONCATENATING TRIMMED FILES"
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		echo $x
		cat trim/"$x"_L00*_1paired.fq.gz > combined/"$x"_R1.fq.gz
		cat trim/"$x"_L00*_2paired.fq.gz > combined/"$x"_R2.fq.gz
done
