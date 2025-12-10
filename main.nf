#!/usr/bin/env nextflow

//Enable strict syntax
//export NXF_SYNTAX_PARSER=v2

//Enable typed processes
nextflow.preview.types = true

// Pipeline parameters
params {
	read_files: String
	phagemid_ref: Path
	matchbox_script: Path
	help: Boolean
	enable_conda: Boolean
}

// Import processes or subworkflows to be run in the workflow
include { header } from './modules/header'
include { minimap2 } from './modules/minimap2'
include { samtools } from './modules/samtools'
include { matchbox } from './modules/matchbox'
include { riot } from './modules/riot'

// Create function to get the barcode from the file name
def get_name(file) {
    return (file.baseName =~ /barcode\d+/)[0]
}

// Help function 
def helpMessage() {
    log.info"""
Usage:  nextflow run main.nf --read_files [input path of fastq files] \\
		--phagemid_ref [reference genome] --matchbox_script [matchbox script]

Required Arguments:
--read_files		: Specify full path of read file(s) location.
--phagemid_ref		: Specify location of the reference genome.
--matchbox_script	: Specify matchbox script.

Optional Arguments:
--output_dir		: Where the output files will be written to (default: "$projectDir/results).
--enable_conda		: Specify whether to enable conda or not. 
-profile		: Specify the profile to run nextflow through.
			  Options - [standard, wehi, conda, singularity, local] (default: standard).
""".stripIndent()
}

// Function for parameter validation
def param_validation() {
	channel.fromPath(params.read_files, checkIfExists: true)
	channel.fromPath(params.phagemid_ref, checkIfExists: true)
	channel.fromPath(params.matchbox_script, checkIfExists: true)
}

workflow {
	main:

	// // Validate correct version is used
	// if( !nextflow.version.matches('>=25.10.2') ) {
    // error "This workflow requires Nextflow version 23.10 or greater -- You are running version $nextflow.version"
	// }

	// Invoke help function if required
	if ( params.help ) {
	helpMessage()
	exit 1
	}
	
	// If none of the above are a problem, then run the workflow
	else {
	// Print pipeline information
	header()
	
	// Validate parameters
	param_validation()

	// Create channel for the read files and extract the barcode from file name as the sample name
	files = channel.fromPath(params.read_files)
	.map {
		file -> tuple(get_name(file), file)
	}

	// QC: Identify % aligning to the reference (gDNA/helper phage contamination)
	minimap_out = minimap2(files, params.phagemid_ref)

	// Convert and index the SAM file format to BAM file format
	sam_out = samtools(minimap_out)

	// Extract heavy and light chain pairs from the reads, and output summary stats
	matchbox_out = matchbox(files, params.matchbox_script)

	// Annotate heavy and light chain sequences
	riot_out = riot(matchbox_out.matchbox_files) 
	}

	// Publish outputs
    publish:
	bam_file = sam_out.aligned_sorted_read
	bam_index = sam_out.index
	aligned_stats = sam_out.aligned_stats
	matchbox_stats = matchbox_out.matchbox_stats
	matchbox_files = matchbox_out.matchbox_files
	annotated_hc = riot_out.annot_heavy
	annotated_lc = riot_out.annot_light

	// Completion message
	onComplete:
	log.info """
	=====================================================================================
	Workflow execution summary
	=====================================================================================

	Completed at	: ${workflow.complete}
	Duration	: ${workflow.duration}
	Success		: ${workflow.success}
	Work directory	: ${workflow.workDir}
	Exit status	: ${workflow.exitStatus}
	results		: ${workflow.outputDir}

	=====================================================================================
	""".stripIndent()
	
	// Error message
	onError:
    log.error "Error: Pipeline execution stopped with the following message: ${workflow.errorMessage}".stripIndent()
}

// Set output paths
output {
	bam_file {
        path "1. aligned reads"
    }
	bam_index {
        path "1. aligned reads"
    }
	aligned_stats {
		path "1. aligned reads/stats"
	}
	matchbox_stats {
		path "2. extracted reads/counts"
	}
	matchbox_files {
		path "2. extracted reads"
	}
	annotated_hc {
		path "3. annotated reads"
	}
	annotated_lc {
		path "3. annotated reads"
	}
}