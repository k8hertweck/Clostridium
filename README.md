# Clostridium

Scripts for assembly and analysis of Clostridium acetobutylicum strains

Scripts:
* `rawQC.sh`: quality assessment of paired-end fastq data with FastQC, quality trimming and filtering with Trimmomatic, reassessment of quality
* `read_mapping.sh`: aligning reads to reference genome (chromosome + pSOL plasmid)
* `variant_calling.sh`: identifying variants (haploid and diploid)
* `identify_filters.sh`: identifying genomes to mask for quality control
* `variant_filtering.sh`: masking portions of genome to identify final sets of SNPs and indels
* `annotation.sh`: identifying function and effects of variants
* `assembly.sh`: selection of kmer value with VelvetOptimizer, genome assembly with Velvet

Output:
* `raw/`: original `fq.gz` forward and reverse data files (multiple pairs per sample)
* `trimmed/`: quality trimmed `fq.gz` forward and reverse data files (multiple pairs per sample)
* `combined/`: one pair (forward and reverse) `fq.gz` file per sample (quality trimmed and concatenated)
* `aln/`: two (F and R) `.sai` files for each sample
* `sampe/`: `pe.bam` for each sample
* `dup/`: `dup.bam` and `dup_metrics.txt` for each sample
* `fixmate/`: `fixmate.bam` for each sample (final file for `read_mapping.slurm`)
* `variants/`: two `.vcf` files (haploid and diploid multisample variant calls)
