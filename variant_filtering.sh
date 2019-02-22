#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT (through interactive shell)
## dependencies
#   GATK (v4.0.8.1): https://software.broadinstitute.org/gatk/ (must install and specify path below)

PROJECT=$1
SCRIPTS=`pwd`
GATK=$HOME/bin/gatk

cd $PROJECT
mkdir filtered

## SNPs
# extract just SNPs
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace_raw_variants_haploid.vcf.gz \
  --select-type-to-include SNP \
  -O filtered/raw_snps.vcf.gz
# apply hard filters to SNPs
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V filtered/raw_snps.vcf.gz \
  -O filtered/filtered_snps.vcf \
  --filter-name "filter1" \
  --filter-expression "QD < 2.0" \
  --filter-name "filter2" \
  --filter-expression "FS > 60.0" \
  --filter-name "filter3" \
  --filter-expression "MQ < 40.0" \
  --filter-name "filter4" \
  --filter-expression "MQRankSum < -12.5" \
  --filter-name "filter5" \
  --filter-expression "ReadPosRankSum < -8.0"
# retrieve passing calls
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -V filtered/filtered_snps.vcf \
  --exclude-filtered \
  -O Cace-snps_filtered.vcf

## indels
# select only INDELS
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V variants/Cace_raw_variants_haploid.vcf.gz \
  --select-type-to-include INDEL \
  -O filtered/raw_indels.vcf.gz
# apply hard filters to SNPs
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
  -V filtered/raw_indels.vcf.gz \
  -O filtered/filtered_indels.vcf \
  --filter-name "filter1" \
  --filter-expression "QD < 2.0" \
  --filter-name "filter2" \
  --filter-expression "FS > 200.0" \
  --filter-name "filter5" \
  --filter-expression "ReadPosRankSum < -20.0"
# retrieve passing calls
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -V filtered/filtered_indels.vcf \
  --exclude-filtered \
  -O Cace-indels_filtered.vcf

# select only heterozygotes from diploid analysis
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  VariantFiltration \
  -R $SCRIPTS/references/Cace-ATCC824-both.fasta \
<<<<<<< HEAD
  -V variants/raw_snps.vcf.gz \
  --sample-expressions "Cace-3003"
  -O variants/test.vcf.gz
=======
  -V variants/Cace_raw_variants_diploid.vcf.gz \
  --genotype-filter-expression "isHet == 1" \
  --genotype-filter-name "isHetFilter" \
  -O filtered/het_diploid_marked.vcf
# remove sites that are exclusively het or non-variant
java -jar $GATK/gatk-package-4.0.8.1-local.jar \
  SelectVariants \
  -V filtered/het_diploid_marked.vcf \
  --set-filtered-gt-to-nocall \
  --exclude-non-variants \
  -O filtered/het_diploid_filtered.vcf
# identify sites with a single het
grep "isHetFilter:" filtered/het_diploid_filtered.vcf > filtered/het_diploid_singletons.txt
# extract hets from diploid analysis
grep "isHetFilter:" filtered/het_diploid_marked.vcf | grep -v "344363" | grep -v "2102314" | cut -f 1,2 > filtered/het_diploid_exclude.txt
# remove hets from snps
grep -v -f filtered/het_diploid_exclude.txt Cace-snps_filtered.vcf > Cace-snps.vcf
# remove hets from indels
grep -v -f filtered/het_diploid_exclude.txt Cace-indels_filtered.vcf > Cace-indels.vcf

## Extra
   # exclude non-reference calls
   # exclude variants in low-complexity regions
   # exclude variants within 6 bases of an indel
>>>>>>> ef928786042288447706158646898673bd51b900
