# Antibody preprocessing pipeline
This nextflow pipeline is designed to assist in processing of antibody long-read sequences. This will align and annotate heavy and light chains from long reads, and provide QC metrics.

## Useful links
* The [documentation website]()
* The [data]()

## Usage
```
Usage:  nextflow run main.nf --read_files [input path of fastq files] \\
        --phagemid_ref [reference genome] --matchbox_script [matchbox script]

--help              : prints this help message

Required Arguments:
--read_files		: Specify full path of read file(s) location.
--phagemid_ref		: Specify location of the reference genome.
--matchbox_script	: Specify matchbox script.

Optional Arguments:
--output_dir        : Where the output files will be written to (default: "$projectDir/results).
--enable_conda		: Specify whether to enable conda or not. 
-profile		    : Specify the profile to run nextflow through.
			          Options - [standard, wehi, conda, singularity, local] (default: standard).
```

## Input
This pipeline requires as input:
* The path of the directory containing the basecalled and demultiplexed nanopore long reads
    - Expects a directory containing all fastq files ending with barcode names (e.g. 1034_barcode1.fastq)
* The reference genome to ne used in fa format
* The matchbox script to split the read into heavy and light chains
* The path of the directory where it should write the results

## Output
This pipeline will produce QC metrics and the annotation results for paired heavy and light chain sequences from all samples. All aligned sequences in BAM format, heavy and light chain sequences in FASTA format, as well as intermediate files (samtools QC results, matchbox stats) are written to the results directory.
