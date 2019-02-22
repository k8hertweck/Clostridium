#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT (through interactive shell)
## dependencies
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/ (must install and specify path below)

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk

cd $PROJECT

# select only heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace-variants_diploid.vcf.gz \
  --genotype-filter-expression "isHet == 1" \ # identify heterozygous variants
  --genotype-filter-name "isHetFilter" \ # label heterozygous variants
  -O variants/het_diploid_marked.vcf
# extract heterozygotes from diploid analysis
grep "isHetFilter" variants/het_diploid_marked.vcf > variants/het_diploid_exclude.txt
# extract header
head -33 variants/het_diploid_marked.vcf > variants/header.txt
# replace header
cat variants/header.txt variants/het_diploid_exclude.txt > variants/het_diploid_exclude.vcf
# exclude heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
   SelectVariants \
   -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
   -V variants/Cace-variants_haploid.vcf.gz \
   --exclude-ids variants/het_diploid_exclude.vcf
   -O variants/haploid_unfiltered.vcf.gz  \

   # exclude non-reference calls
   # exclude sites with extremely high depths of coverage
   # exclude variants in low-complexity regions

## SNPs
# extract just SNPs
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/haploid_unfiltered.vcf.gz \
  --select-type-to-include SNP
  -O variants/raw_snps.vcf.gz

# exclude variants within 6 bases of an indel

# transform filtered genotypes to no call
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -V XXX.vcf \
  --set-filtered-gt-to-nocall \
  -O Cace-snps.vcf

## indels
# select only INDELS
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/haploid_unfiltered.vcf.gz \
  --select-type-to-include INDEL \
  -O variants/raw_indels.vcf.gz

# separate by sample
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/raw_snps.vcf.gz \
  --sample-expressions "Cace-3003"
  -O variants/test.vcf.gz
