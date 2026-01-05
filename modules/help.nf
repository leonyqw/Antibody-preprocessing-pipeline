#!/usr/bin/env nextflow

//Enable typed processes
nextflow.preview.types = true

// Print help message information
workflow helpMessage {

    if ( params.help ) {
        log.info"""
Usage:  nextflow run main.nf --read_files [input path of fastq files] \\
		--phagemid_ref [reference genome] --matchbox_script [matchbox script]

Required Arguments:
--read_files		: Specify full path of read file(s) location.
--phagemid_ref		: Specify location of the reference genome.
--matchbox_script	: Specify matchbox script.

Optional Arguments:
--output_dir		: Where the output files will be written to (default: "$projectDir/results").
-profile		: Specify the profile to run nextflow through.
			  Options - [standard, wehi, conda, singularity, local] (default: standard).
""".stripIndent()
    
    exit 1
    }
}