#!/bin/bash

#SBATCH -J read_mapping	# Job name
#SBATCH -o read_mapping.%j.out	# Name of stdout output file (%j expands to jobId)
#SBATCH -p normal	# Queue name
#SBATCH -N 1	# Total number of nodes requested
#SBATCH -n 16 	# Total number of tasks requested
#SBATCH -t 48:00:00	# Run time (hh:mm:ss)
#SBATCH --mail-user k8hertweck@gmail.com	# email to notify
#SBATCH --mail-type=ALL	# when to notify email
#SBATCH -A Clostridium-genomics	# Allocation name to charge job against

## read mapping of Clostridium strains
## usage: sbatch read_mapping.slurm PATH/TO/PROJECT
## dependencies
# 	bwa (v0.7.16a): http://bio-bwa.sourceforge.net
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   samtools (v1.5): http://www.htslib.org

module load intel/17.0.4 bwa/0.7.16a picard/2.11.0 samtools/1.5

PROJECT=$1
SCRIPTS=`pwd`

cd $SCRIPTS

## index reference genome
cd references
echo "INDEXING REFERENCE"
bwa index Cace-ATCC824-both.fasta

## read mapping
cd $PROJECT
mkdir aln sampe dup fixmate groups
# map reads to reference
echo "MAPPING READS"
# read mapping and duplicate removal for each sample
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
  do
    # find suffix array (SA) coordinates
    bwa aln -t 16 $SCRIPTS/references/Cace-ATCC824-both.fasta \
      combined/"$x"_R1.fq.gz > aln/"$x"_R1.sai
    bwa aln -t 16 $SCRIPTS/references/Cace-ATCC824-both.fasta \
      combined/"$x"_R2.fq.gz > aln/"$x"_R2.sai
    # generate alignments for paired end reads in SAM format
    bwa sampe $SCRIPTS/references/Cace-ATCC824-both.fasta \
      aln/"$x"_R1.sai aln/"$x"_R2.sai \
      combined/"$x"_R1.fq.gz \
      combined/"$x"_R2.fq.gz | \
      samtools view -S -b - | \
      samtools sort - > sampe/"$x"-pe.bam
    # identify duplicates
    java -jar $TACC_PICARD_DIR/build/libs/picard.jar \
      MarkDuplicates \
      VALIDATION_STRINGENCY=LENIENT \
      I=sampe/"$x"-pe.bam \
      O=dup/"$x"_dup.bam \
      M=dup/"$x"_dup_metrics.txt
    # remove pairs with at least one read marked as duplicate
    java -jar $TACC_PICARD_DIR/build/libs/picard.jar \
      FixMateInformation \
      VALIDATION_STRINGENCY=LENIENT \
      I=dup/"$x"_dup.bam \
      O=fixmate/"$x"_fixmate.bam
    # validate file
    #java -jar $TACC_PICARD_DIR/build/libs/picard.jar \
    #    ValidateSamFile \
    #    I=fixmate/"$x"_fixmate.bam
    # resolve groups
    java -jar $TACC_PICARD_DIR/build/libs/picard.jar \
      AddOrReplaceReadGroups \
      VALIDATION_STRINGENCY=LENIENT \
      I=fixmate/"$x"_fixmate.bam \
      O=groups/"$x"_groups.bam \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=20
  done
