#!/bin/bash

## annotating variants
## usage: annotation.sh PATH/TO/DIRECTORY/WITH/VCFs
## dependencies
#   snpEff (http://snpeff.sourceforge.net)

# set path to snpEff
SNPEFF=/Applications/snpEff_latest_core/snpEff/

cd $ANALYSIS

# identify effects of SNPs
for x in Cace-snps.vcf Cace-indels.vcf
  do
    sed s/NC_003030.1/Chromosome/ $x | sed s/NC_001988.2/megaplasmid/ > snpeff.$x
done

for x in snps indels
  do
    mkdir $x
    cd $x
    java -jar $SNPEFF/snpEff.jar Clostridium_acetobutylicum_atcc_824 ../snpeff.Cace-"$x".vcf > "$x"_annotations.vcf
    java -jar $SNPEFF/snpEff.jar Clostridium_acetobutylicum_atcc_824 -csvStats $x.csv ../snpeff.Cace-"$x".vcf > "$x"_annotations.vcf
    cd ..
done
