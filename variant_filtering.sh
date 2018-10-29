#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (vXXX): https://software.broadinstitute.org/gatk/

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk/

cd $SCRIPTS

## SNPs
# exclude variants within 6 bases of an indel
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/test.vcf.gz \
  --select-type-to-include SNP
  -O variants/filtered_test.vcf
# exclude variants called as heterozygotes in diploid analysis
SelectVariants
# exclude non-reference calls
SelectVariants
# exclude sites with extremely high depths of coverage
SelectVariants
# exclude variants in low-complexity regions
SelectVariants

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
