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

cd $SCRIPTS

## index reference genome
# bwa and samtools require the index to be referenced to perform comparisons with reads
cd references
echo "INDEXING REFERENCE"
bwa index targetGeneRefs.fas
samtools faidx targetGeneRefs.fas

cd $PROJECT

## read mapping
mkdir mappingGenes resultsGenes

# loop across all strains
for x in 463_S1 3003_S5 7960_S6 7966_S7 7971_S8 7979_S9 7984_S10 8002_S11 8005_S12 824_S3
	do

# map reads to reference: find locations in known genome where reads match
echo "MAPPING READS"
bwa mem -t 2 $SCRIPTS/references/targetGeneRefs.fas combined/Cace-"$x"_R1.fq.gz combined/Cace-"$x"_R2.fq.gz > mappingGenes/Cace-"$x".sam
# convert sam to sorted bam format
echo "CONVERTING SAM TO BAM"
samtools view -bS mappingGenes/Cace-"$x".sam | samtools sort > mappingGenes/Cace-"$x".sorted.bam
# print simple summary statistics for read mapping
echo "SUMMARIZE READ MAPPING"
samtools flagstat mappingGenes/Cace-"$x".sorted.bam > resultsGenes/Cace-"$x".summary.txt
# index bam file
echo "INDEXING BAM FILE"
samtools index mappingGenes/Cace-"$x".sorted.bam
# add average depth of coverage to summary file
echo "CALCULATING DEPTH OF COVERAGE"
samtools depth mappingGenes/Cace-"$x".sorted.bam >> resultsGenes/Cace-"$x".summary.txt
samtools depth mappingGenes/Cace-"$x".sorted.bam | awk '{sum+=$3} END { print "Average coverage= ",sum/NR}' >> resultsGenes/Cace-"$x".summary.txt

## variant calling
# find SNPs in reads relative to reference
echo "CALLING VARIANTS"
samtools mpileup -ugf $SCRIPTS/references/targetGeneRefs.fas mappingGenes/Cace-"$x".sorted.bam > mappingGenes/Cace-"$x".raw.bcf
# filter SNPs and keep only those with substantial data
echo "FILTERING SNPS"
bcftools view mappingGenes/Cace-"$x".raw.bcf | vcfutils.pl varFilter -D100 > resultsGenes/Cace-"$x".flt.vcf
# summarize SNPs
echo "SUMMARIZE SNPs"
echo -e "QUAL\t#non-indel\t#SNPs\t#transitions\t#joint\tts/tv\t#joint/#ref #joint/#non-indel" > resultsGenes/Cace-"$x".snps.txt
vcfutils.pl qstats resultsGenes/Cace-"$x".flt.vcf >> resultsGenes/Cace-"$x".snps.txt

done