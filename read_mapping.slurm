#!/bin/bash

#SBATCH -J read_mapping	# Job name
#SBATCH -o read_mapping.%j.out	# Name of stdout output file (%j expands to jobId)
#SBATCH -p normal	# Queue name
#SBATCH -n 16	# Total number of  tasks requested
#SBATCH -t 48:00:00	# Run time (hh:mm:ss)
#SBATCH --mail-user k8hertweck@gmail.com	# email to notify
#SBATCH --mail-type=ALL	# when to notify email
#SBATCH -A Clostridium-genomics	# Allocation name to charge job against

## read mapping of Clostridium strains
## usage: read_mapping.sh PATH/TO/PROJECT
## dependencies
# 	bwa (v0.7.12-r1039): http://bio-bwa.sourceforge.net
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/

module load intel/17.0.4 bwa/0.7.16a picard/2.11.0 gatk/3.8.0

PROJECT=$1
SCRIPTS=`pwd`

cd $SCRIPTS

## index reference genome
cd references
echo "INDEXING REFERENCE"
bwa index Cace-ATCC824-both.fas
cd $PROJECT

## read mapping
mkdir mapping
# map reads to reference
echo "MAPPING READS"
# find suffix array (SA) coordinates
bwa aln
$SCRIPTS/references/Cace-ATCC824-both.fas (reference)
combined/Cace-3003_S5_R1.fq.gz combined/Cace-3003_S5_R2.fq.gz (input)
mapping/ (output)
# generate alignments for paired end reads in SAM format
bwa sampe (default)
# identify duplicates
MarkDuplicates (picard)
# remove pairs with at least one read marked as duplicate
FixMateInformation (picard)
# realign reads to minimize SNPs in indel regions
RealignerTargetCreator/IndelRealigner (gatk)