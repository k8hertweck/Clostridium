#!/bin/bash

## assembly of microbial genomes
## usage: assembly.sh PATH/TO/PROJECT
#	run raw.QC.sh first
#	set VELOPS to wherever VelvetOptimiser is installed
## dependencies
#	VelvetOptimizer (v2.2.5): identifies parameters for Velvet
#		(https://github.com/tseemann/VelvetOptimiser)
#	Velvet (Version 1.2.10): genome assembly 
#		(https://www.ebi.ac.uk/~zerbino/velvet/Manual.pdf), installed and in path

PROJECT=$1
SCRIPTS=`pwd`
VELOPS=/Applications/VelvetOptimiser-2.2.5

cd $PROJECT

# velvet optimizer (testing on 3003; 31 is best)
#$VELOPS/VelvetOptimiser.pl -s 27 -e 31 -f '-shortPaired -fastq -separate combined/Cace-3003_S5_R1.fq.gz combined/Cace-3003_S5_R2.fq.gz'

# loop assembly across all samples
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
	do
		# assemble genome
		velveth $x.31 31 -shortPaired -fastq -separate combined/$x_R1.fq.gz combined/$x_R2.fq.gz
		velvetg $x.31 -cov_cutoff auto -exp_cov auto
done
