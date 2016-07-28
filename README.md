# Clostridium

Scripts for assembly and analysis of Clostridium acetobutylicum strains

Scripts:
* `rawQC.sh`: quality assessment of paired-end *.fastq data with FastQC, quality trimming and filtering with Trimmomatic, reassessment of quality
* `assembly.sh`: selection of kmer value with VelvetOptimizer, genome assembly with Velvet, aligning contigs with ProgressiveMauve
