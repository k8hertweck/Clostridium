#!/bin/bash

## variant calling for Clostridium strains 
## usage: variant_calling.sh PATH/TO/PROJECT
## dependencies
#   Picard-tools (v2.11.0): http://broadinstitute.github.io/picard
#   GATK (v3.8.0): https://software.broadinstitute.org/gatk/

## pre-process reads
# combine strain data
MergeSamFiles (picard)
# realign reads
RealignerTargetCreator/IndelRealigner (gatk)
# filter out reads with zero mapping quality and low base quality
gatk

## call variants
# haploid
UnifiedGenotyper (picard, configure for haploid genomes)
# diploid (for false-positive filtering)
UnifiedGenotyper (picard, configure for diploid genomes)
