#!/bin/bash

## summarization of data
# usage: ./summary.sh PATH/TO/DATA

DATA=~/data/Clostridium

# raw data
cd raw
for x in Cace*R1_001.fastq.gz
  do
    echo $x
    zcat < $x | grep "@" | wc -l
done

# trimmed data
cd combined
for x in Cace*R1.fq.gz
  do
    echo $x
    zcat < $x | grep "@" | wc -l
done
