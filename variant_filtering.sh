#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT
## dependencies
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/ (must install and specify path below)

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk

cd $SCRIPTS

# identify heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace-variants_diploid.vcf.gz \
  --genotype-filter-expression "isHet == 1" \ # identify heterozygous variants
  --genotype-filter-name "isHetFilter" \ # label heterozygous variants
  -O variants/het_diploid_marked.vcf
# extract heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace-variants_diploid.vcf.gz \
  -select "isHet == 1" \
  -O variants/het_diploid_exclude.vcf
# exclude heterozygotes from diploid analysis
java -jar GenomeAnalysisTK.jar \
   -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
   -T SelectVariants \
   --variant input.vcf \
   -o output.vcf \
   -excludeIDs fileExclude


## SNPs
# extract just SNPs from callset
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/XXX.vcf \
  --select-type-to-include SNP
# exclude heterozygotes from diploid analysis

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
  -O Cace-snps.vcf

## indels
# exclude variants called as heterozygotes in diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/raw_indels.vcf.gz \
  --select-type-to-include INDEL
# exclude non-reference calls

# exclude sites with extremely high depths of coverage

# exclude variants in low-complexity regions
