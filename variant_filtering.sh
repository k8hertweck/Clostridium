#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT
## dependencies
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/ (must install and specify path below)

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk

cd $SCRIPTS

# extract heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace-variants_diploid.vcf.gz \
  --genotype-filter-expression "isHet == 1" \ # identify heterozygous variants
  --genotype-filter-name "isHetFilter" \ # label heterozygous variants
  -O variants/test_diploid.vcf

## SNPs
# annotate SNPs to remove
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/test.vcf.gz \
  --select-type-to-include SNP
  
  # exclude variants within 6 bases of an indel
  # exclude non-reference calls
  # exclude sites with extremely high depths of coverage
  # exclude variants in low-complexity regions
  -O variants/filtered_test.vcf
# transform filtered genotypes to no call
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -V XXX.vcf \
  --set-filtered-gt-to-nocall \
  -O output.vcf

## indels
# exclude variants called as heterozygotes in diploid analysis
SelectVariants
--select-type-to-include INDEL
# exclude non-reference calls
SelectVariants
# exclude sites with extremely high depths of coverage
SelectVariants
# exclude variants in low-complexity regions
SelectVariants
