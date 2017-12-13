#!/bin/bash

## read mapping of Clostridium strains
## usage: mapping.sh PATH/TO/PROJECT
## dependencies
# 	bwa (v0.7.12-r1039): read mapping
#		(http://bio-bwa.sourceforge.net)
# 	samtools (v1.3.1, using htslib 1.3.1): ngs manipulation
#		(http://www.htslib.org)
#	bcftools (v1.2, using htslib 1.2.1) and vcfutils.pl: variant call analysis
#		(https://samtools.github.io/bcftools/bcftools.html), installed and in path

PROJECT=$1
SCRIPTS=`pwd`

cd $PROJECT
mkdir mapping

## index reference genome
# bwa and samtools require the index to be referenced to perform comparisons with reads
cd references
echo "INDEXING REFERENCE"
bwa index Cace-ATCC824-chrom.fas
samtools faidx Cace-ATCC824-chrom.fas

## read mapping
cd $PROJECT
mkdir mapping results
# map reads to reference: find locations in known genome where reads match
echo "MAPPING READS"
bwa mem -t 2 $SCRIPTS/references/Cace-ATCC824-chrom.fas combined/Cace-3003_S5_R1.fq.gz combined/Cace-3003_S5_R2.fq.gz > mapping/Cace-3003_S5_ATCC824.sam
# convert sam to sorted bam format
echo "CONVERTING SAM TO BAM"
samtools view -bS mapping/Cace-3003_S5_ATCC824.sam | samtools sort > mapping/Cace-3003_S5_ATCC824.sorted.bam
# print simple summary statistics for read mapping
echo "SUMMARIZE READ MAPPING"
samtools flagstat mapping/Cace-3003_S5_ATCC824.sorted.bam > results/Cace-3003_S5_ATCC824.summary.txt
# add average depth of coverage to summary file
echo "CALCULATING DEPTH OF COVERAGE"
samtools depth mapping/Cace-3003_S5_ATCC824.sorted.bam | awk '{sum+=$3} END { print "Average coverage= ",sum/NR}' >> results/Cace-3003_S5_ATCC824.summary.txt

## variant calling
# find SNPs in reads relative to reference
echo "CALLING VARIANTS"
samtools mpileup -ugf $SCRIPTS/references/Cace-ATCC824-chrom.fas mapping/Cace-3003_S5_ATCC824.sorted.bam > mapping/Cace-3003_S5_ATCC824.raw.bcf
# filter SNPs and keep only those with substantial data
echo "FILTERING SNPS"
bcftools view mapping/Cace-3003_S5_ATCC824.raw.bcf | vcfutils.pl varFilter -D100 > results/Cace-3003_S5_ATCC824.flt.vcf
# summarize SNPs
echo "SUMMARIZE SNPs"
echo -e "QUAL\t#non-indel\t#SNPs\t#transitions\t#joint\tts/tv\t#joint/#ref #joint/#non-indel" > results/Cace-3003_S5_ATCC824.snps.txt
vcfutils.pl qstats results/Cace-3003_S5_ATCC824.flt.vcf >> results/Cace-3003_S5_ATCC824.snps.txt
