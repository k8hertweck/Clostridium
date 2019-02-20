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
# 	bwa (v0.7.16a): http://bio-bwa.sourceforge.net (TACC installed)
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard (TACC installed)
#   samtools (v1.5): http://www.htslib.org (TACC installed)
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/ (must install and specify path below)

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
samtools faidx Cace-ATCC824-both.fasta
cd $PROJECT
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
  do
    samtools index groups/"$x"_groups.bam
  done

cd $PROJECT
mkdir variants

# variant calling on each sample individually
for x in `cat $SCRIPTS/ClostridiumStrains.lst`
  do
    # haploid
    java -jar $GATK/gatk-package-4.0.8.1-local.jar \
      HaplotypeCaller \
      -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
      -I groups/"$x"_groups.bam \
      -O variants/"$x"_variants_haploid.vcf.gz \
      -bamout variants/"$x"_variants_haploid.bam \
      -ERC GVCF \
      -mbq 15 \
      -ploidy 1
    # diploid (for false-positive filtering)
    java -jar $GATK/gatk-package-4.0.8.1-local.jar \
      HaplotypeCaller \
      -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
      -I groups/"$x"_groups.bam \
      -O variants/"$x"_variants_diploid.vcf.gz \
      -bamout variants/"$x"_variants_diploid.bam \
      -ERC GVCF \
      -mbq 15
done

# merge files
for x in haploid diploid
  do
    java -jar $GATK/gatk-package-4.0.8.1-local.jar \
      CombineGVCFs \
      -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
      --variant variants/Cace-3003_S5_variants_"$x".vcf.gz \
      --variant variants/Cace-463_S1_variants_"$x".vcf.gz \
      --variant variants/Cace-7960_S6_variants_"$x".vcf.gz \
      --variant variants/Cace-7966_S7_variants_"$x".vcf.gz \
      --variant variants/Cace-7971_S8_variants_"$x".vcf.gz \
      --variant variants/Cace-7979_S9_variants_"$x".vcf.gz \
      --variant variants/Cace-7984_S10_variants_"$x".vcf.gz \
      --variant variants/Cace-8002_S11_variants_"$x".vcf.gz \
      --variant variants/Cace-8005_S12_variants_"$x".vcf.gz \
      --variant variants/Cace-824_S3_variants_"$x".vcf.gz \
      -O variants/Cace_combined_variants_"$x".vcf.gz
    # perform joint variant calling
    java -jar $GATK/gatk-package-4.0.8.1-local.jar \
      GenotypeGVCFs \
      -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
      -V variants/Cace_combined_variants_"$x".vcf.gz \
      -O variants/Cace_raw_variants_"$x".vcf.gz
done
