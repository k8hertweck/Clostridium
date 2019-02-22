#!/bin/bash

## phylogenetics for Cace
# usage: this script isn't completely executable as-is, since a file conversion is required. 

# clean up data export from Geneious
cut -d " " -f 1 *.fasta | sed s/\_\-\_16Sa\_rRNA// | sed s/\-\_16Sa\_rRNA// > Cace-16S.fasta
# file conversion with Aliview (fasta to phy)

# build ML phylogeny
raxml -f a -# 1000 -n Cace -o Bsubtilisoutgroup -m GTRGAMMA -x 3452345 -s Cace-16S.phy -p 35645 -T 2
