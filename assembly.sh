#!/bin/bash

## assembly of microbial genomes
## dependencies
#	VelvetOptimizer
#	Velvet
#	progressiveMauve

DATA=$1
SCRIPTS=`pwd`

cd $WORK/genomicsProject/data

# velvet optimizer

# assemble genome
velveth assembly 51 -fastq XXX.fastq
velvetg assembly -cov_cutoff auto -exp_cov auto

# align contigs with progressiveMauve