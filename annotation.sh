#!/bin/bash

## annotating variants
## usage: variant_calling.sh PATH/TO/PROJECT
## dependencies
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/
#   snpEff (http://snpeff.sourceforge.net)
#   SNAP https://www.hiv.lanl.gov/content/sequence/SNAP/SNAP.html

# identify effects of SNPs
snpEff
# reduce to single most damaging effect
VariantAnnotator (gatk)
# estimate synonymous and nonsynonymous nucleotide diversity
SNAP on variants including low complexity
