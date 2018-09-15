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
## usage: sbatch read_mapping.slurm PATH/TO/PROJECT
## dependencies
# 	bwa (v0.7.16a): http://bio-bwa.sourceforge.net
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/
#   samtools (v1.5): http://www.htslib.org

module load intel/17.0.4 bwa/0.7.16a picard/2.11.0 gatk/3.8.0 samtools/1.5

PROJECT=$1
SCRIPTS=`pwd`

cd $SCRIPTS

## index reference genome
cd references
echo "INDEXING REFERENCE"
bwa index Cace-ATCC824-both.fas

## read mapping
cd $PROJECT
mkdir aln sampe dup fixmate realign
# map reads to reference
echo "MAPPING READS"
# find suffix array (SA) coordinates
bwa aln -t 16 $SCRIPTS/references/Cace-ATCC824-both.fas \
  combined/Cace-3003_S5_R1.fq.gz > aln/Cace-3003_S5_R1.sai
bwa aln -t 16 $SCRIPTS/references/Cace-ATCC824-both.fas \
  combined/Cace-3003_S5_R2.fq.gz > aln/Cace-3003_S5_R2.sai
# generate alignments for paired end reads in SAM format
bwa sampe $SCRIPTS/references/Cace-ATCC824-both.fas \
  aln/Cace-3003_S5_R1.sai aln/Cace-3003_S5_R2.sai \
  combined/Cace-3003_S5_R1.fq.gz \
  combined/Cace-3003_S5_R2.fq.gz | \
  samtools view -S -b - > sampe/Cace-3003_S5-pe.bam
# identify duplicates
java jvm-args -jar $TACC_PICARD_DIR/build/libs/picard.jar \
  MarkDuplicates \
  I=sampe/Cace-3003_S5-pe.bam \
  O=dup/Cace-3003_S5_dup.bam \
  M=dup/Cace-3003_S5_dup_metrics.txt
# remove pairs with at least one read marked as duplicate
java jvm-args -jar $TACC_PICARD_DIR/build/libs/picard.jar \
  FixMateInformation \
  I=dup/Cace-3003_S5_dup.bam \
  O=fixmate/Cace-3003_S5_fixmate.bam
# realign reads to minimize SNPs in indel regions
java -jar $TACC_GATK_DIR/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  $SCRIPTS/references/Cace-ATCC824-both.fas \
  -I fixmate/Cace-3003_S5_fixmate.bam \
  -o realign/Cace-3003_S5.intervals
java -jar $TACC_GATK_DIR/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  $SCRIPTS/references/Cace-ATCC824-both.fas \
  -I fixmate/Cace-3003_S5_fixmate.bam \
  -targetIntervals realign/Cace-3003_S5.intervals \
  -o realign/Cace-3003_S5_realign.bam
