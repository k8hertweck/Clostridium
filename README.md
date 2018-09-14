# Clostridium

Scripts for assembly and analysis of Clostridium acetobutylicum strains

Scripts:
* `rawQC.sh`: quality assessment of paired-end fastq data with FastQC, quality trimming and filtering with Trimmomatic, reassessment of quality
* `read_mapping.sh`: aligning reads to reference genome (chromosome + pSOL plasmid)
* `variant_calling.sh`: identifying variants (haploid and diploid)
* `identify_filters.sh`: identifying genomes to mask for quality control
* `variant_filtering.sh`: masking portions of genome to identify final sets of SNPs and indels
* `assembly.sh`: selection of kmer value with VelvetOptimizer, genome assembly with Velvet
