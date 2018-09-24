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

module load intel/17.0.4 bwa/0.7.16a picard/2.11.0 gatk/3.8.0 samtools/1.5

## variant calling for Clostridium strains
## usage: variant_calling.sh PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/

PROJECT=$1
SCRIPTS=`pwd`

cd $PROJECT/
mkdir variants

# multi-sample variant calling, haploid
java -jar GenomeAnalysisTK.jar \
  -T HaplotypeCaller \
  -R $SCRIPTS/references/Cace-ATCC824-both.fas \
  -I fixmate/Cace-3003_S5_fixmate.bam \
  -I fixmate/Cace-463_S1_fixmate.bam \
  -I fixmate/Cace-7960_S6_fixmate.bam \
  -I fixmate/Cace-7966_S7_fixmate.bam \
  -I fixmate/Cace-7971_S8_fixmate.bam \
  -I fixmate/Cace-7979_S9_fixmate.bam \
  -I fixmate/Cace-7984_S10_fixmate.bam \
  -I fixmate/Cace-8002_S11_fixmate.bam \
  -I fixmate/Cace-8005_S12_fixmate.bam \
  -I fixmate/Cace-824_S3_fixmate.bam \
  -o variants/Cace-variants.bam \
  -mmq 15 \
  -ploidy 1
  # multi-sample variant calling, diploid (for false-positive filtering)
java -jar GenomeAnalysisTK.jar \
  -T HaplotypeCaller \
  -R $SCRIPTS/references/Cace-ATCC824-both.fas \
  -I fixmate/Cace-3003_S5_fixmate.bam \
  -I fixmate/Cace-463_S1_fixmate.bam \
  -I fixmate/Cace-7960_S6_fixmate.bam \
  -I fixmate/Cace-7966_S7_fixmate.bam \
  -I fixmate/Cace-7971_S8_fixmate.bam \
  -I fixmate/Cace-7979_S9_fixmate.bam \
  -I fixmate/Cace-7984_S10_fixmate.bam \
  -I fixmate/Cace-8002_S11_fixmate.bam \
  -I fixmate/Cace-8005_S12_fixmate.bam \
  -I fixmate/Cace-824_S3_fixmate.bam \
  -o variants/Cace-variants_diploid.bam \
  -mmq 15
