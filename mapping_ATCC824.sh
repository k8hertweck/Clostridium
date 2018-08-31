#!/bin/bash

## read mapping of Clostridium strains
## usage: mapping_ATCC824.sh PATH/TO/PROJECT
## dependencies
# 	bwa (v0.7.12-r1039): read mapping (http://bio-bwa.sourceforge.net)
#   Picard-tools
#   GATK

PROJECT=$1
SCRIPTS=`pwd`

cd $SCRIPTS

## index reference genome
# bwa and samtools require the index to be referenced to perform comparisons with reads
cd references
echo "INDEXING REFERENCE"
bwa index Cace-ATCC824-both.fas

cd $PROJECT

## read mapping
mkdir mapping results
# map reads to reference
echo "MAPPING READS"
bwa aln
$SCRIPTS/references/Cace-ATCC824-both.fas
combined/Cace-3003_S5_R1.fq.gz
combined/Cace-3003_S5_R2.fq.gz
mapping/

bwa sampe 
