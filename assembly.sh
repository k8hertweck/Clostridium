#!/bin/bash

## assembly of microbial genomes
## dependencies
#	VelvetOptimizer
#	Velvet
#	progressiveMauve

CLOS=$1
SCRIPTS=`pwd`

cd $CLOS

# create list of strains

# velvet optimizer

# loop across all samples
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		# concatenate read files
		zcat trim/$x_L00*_1paired.fq.gz > trim/$x_R1.fq.gz
		zcat trim/$x_L00*_2paired.fq.gz > trim/$x_R2.fq.gz
		# assemble genome
		velveth $x.31 31 -shortPaired -fastq -separate trim/$x_R1.fq.gz trim/$x_R2.fq.gz
		velvetg $x.31 -cov_cutoff auto -exp_cov auto
done

# align contigs with progressiveMauve
