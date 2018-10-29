#!/bin/bash

#SBATCH -J variant_calling	# Job name
#SBATCH -o variant_calling.%j.out	# Name of stdout output file (%j expands to jobId)
#SBATCH -p normal	# Queue name
#SBATCH -N 1	# Total number of nodes requested
#SBATCH -n 16 	# Total number of tasks requested
#SBATCH -t 48:00:00	# Run time (hh:mm:ss)
#SBATCH --mail-user k8hertweck@gmail.com	# email to notify
#SBATCH --mail-type=ALL	# when to notify email
#SBATCH -A Clostridium-genomics	# Allocation name to charge job against

## variant calling for Clostridium strains
## usage: sbatch variant_calling.slurm PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/

module load intel/17.0.4 bwa/0.7.16a picard/2.11.0 samtools/1.5

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk/

cd $SCRIPTS

# prepare reference files
cd references
java -jar $TACC_PICARD_DIR/build/libs/picard.jar \
  CreateSequenceDictionary \
  R=Cace-ATCC824-both.fasta \
  O=Cace-ATCC824-both.dict
samtools faidx Cace-ATCC824-both.fas
cd $PROJECT
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
  do
    samtools index groups/"$x"_groups.bam
  done

cd $PROJECT
mkdir variants

# multi-sample variant calling, haploid
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  HaplotypeCaller \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -I groups/Cace-3003_S5_groups.bam \
  -I groups/Cace-463_S1_groups.bam \
  -I groups/Cace-7960_S6_groups.bam \
  -I groups/Cace-7966_S7_groups.bam \
  -I groups/Cace-7971_S8_groups.bam \
  -I groups/Cace-7979_S9_groups.bam \
  -I groups/Cace-7984_S10_groups.bam \
  -I groups/Cace-8002_S11_groups.bam \
  -I groups/Cace-8005_S12_groups.bam \
  -I groups/Cace-824_S3_groups.bam \
  -O variants/Cace-variants_haploid.vcf.gz \
  -bamout variants/Cace-variants_haploid.bam \
  -mbq 15 \
  -ploidy 1
  # multi-sample variant calling, diploid (for false-positive filtering)
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  HaplotypeCaller \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -I groups/Cace-3003_S5_groups.bam \
  -I groups/Cace-463_S1_groups.bam \
  -I groups/Cace-7960_S6_groups.bam \
  -I groups/Cace-7966_S7_groups.bam \
  -I groups/Cace-7971_S8_groups.bam \
  -I groups/Cace-7979_S9_groups.bam \
  -I groups/Cace-7984_S10_groups.bam \
  -I groups/Cace-8002_S11_groups.bam \
  -I groups/Cace-8005_S12_groups.bam \
  -I groups/Cace-824_S3_groups.bam \
  -O variants/Cace-variants_diploid.vcf.gz \
  -bamout variants/Cace-variants_diploid.bam \
  -mbq 15
