#!/bin/bash

#SBATCH -J clostridium	# Job name
#SBATCH -o clostridium.%j.out	# Name of stdout output file (%j expands to jobId)
#SBATCH -p development	# Queue name
#SBATCH -n 16	# Total number of  tasks requested
#SBATCH -t 2:00:00	# Run time (hh:mm:ss) 
#SBATCH --mail-user EMAIL@someplace.com	# email to notify	
#SBATCH --mail-type END	# when to notify email
#SBATCH -A UT-Tyler-Bioinformat	# Allocation name to charge job against

## assembly of microbial genomes
## dependencies
#	VelvetOptimizer
#	Velvet
#	progressiveMauve

DATA=$1
SCRIPTS=`pwd`

module load velvet

cd $WORK/genomicsProject/data

# velvet optimizer

# assemble genome
velveth assembly 51 -fastq XXX.fastq
velvetg assembly -cov_cutoff auto -exp_cov auto

# align contigs with progressiveMauve
