#!/bin/bash

## assembly of microbial genomes
## usage: assembly.sh PATH/TO/WORKING
## dependencies
#	VelvetOptimizer: specify path (https://github.com/tseemann/VelvetOptimiser)
#	Velvet: installed
# 	whole-genome alignment method? 

CLOS=$1
SCRIPTS=`pwd`
VELOPS=~/Desktop/VelvetOptimiser/

# create list of strains
sed s/_L00[1-5]// ClostridiumFiles.lst | uniq > ClostridiumStrains.lst

cd $CLOS

# velvet optimizer (testing on 3003; 31 is best)
#$VELOPS/VelvetOptimiser.pl -s 27 -e 31 -f '-shortPaired -fastq -separate trim/Cace-3003_S5_R1.fq.gz trim/Cace-3003_S5_R2.fq.gz'

# loop assembly across all samples
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		# concatenate read files
		echo $x
		zcat trim/$x_L00*_1paired.fq.gz > trim/$x_R1.fq.gz
		zcat trim/$x_L00*_2paired.fq.gz > trim/$x_R2.fq.gz
		# assemble genome
		velveth $x.31 31 -shortPaired -fastq -separate trim/$x_R1.fq.gz trim/$x_R2.fq.gz
		velvetg $x.31 -cov_cutoff auto -exp_cov auto
done

# align contigs with progressiveMauve, MUMmer
