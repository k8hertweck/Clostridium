#!/bin/bash

## identifying variants to filter for Clostridium strains
## usage: identify_filters.sh PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/

# cap base qualities at mapping quality

# Base Alignment Quality (BAQ) method: identify variants within 6 bases of indel
mask with FilterVariants (gatk)
# identify low-complexity regions
mdust
FilterVariants
# identify non-reference calls in re-sequenced ATCC824
FilterVariants
# identify sites with extremely high depths of coverage
call external R script
FilterVariants
