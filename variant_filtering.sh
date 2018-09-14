#!/bin/bash

## applying quality filters for Clostridium strains
## usage: variant_filtering.sh PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/

## SNPs
# exclude variants within 6 bases of an indel
SelectVariants
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
# exclude non-reference calls
SelectVariants
# exclude sites with extremely high depths of coverage
SelectVariants
# exclude variants in low-complexity regions
SelectVariants
