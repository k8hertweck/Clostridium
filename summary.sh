#!/bin/bash

## summarization of data
# usage: ./summary.sh PATH/TO/DATA PATH/TO/ANALYSIS
# dependencies: samtools

# summarize raw data
cd $1
cd raw
for x in Cace*R1_001.fastq.gz
  do
    echo $x
    zcat < $x | grep "@" | wc -l
done

# summarize trimmed data
cd combined
for x in Cace*R1.fq.gz
  do
    echo $x
    zcat < $x | grep "@" | wc -l
done

# summarize read mapping
cd $2
# raw mapped reads
for x in sampe/*.bam
  do
    echo $x >> sampe.summary.txt
    samtools depth "$x" | awk '{sum+=$3} END { print "Average coverage= ",sum/NR}' >> sampe.summary.txt
done
# deduplicated mapped reads
for x in sampe/*.bam
  do
    echo $x >> groups.summary.txt
    samtools depth "$x" | awk '{sum+=$3} END { print "Average coverage= ",sum/NR}' >> groups.summary.txt
done
