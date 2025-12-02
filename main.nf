#!/usr/bin/env nextflow

//Enable strict syntax
//export NXF_SYNTAX_PARSER=v2
//export NXF_DATE_FORMAT="yyyy-MM-dd HH:mm:ss"

//Enable typed processes
nextflow.preview.types = true

// Pipeline parameters
params {
	read_files: String
	phagemid_ref: Path
	matchbox_path: Path
	// matchbox_path=/vast/projects/antibody_sequencing/matchbox/target/release/matchbox
	matchbox_antibody_preprocess_script: Path
	// matchbox_script=/vast/projects/antibody_sequencing/PC008/antibody_preprocess.mb
	help: Boolean
	github_location: String
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

/// Help function 
// def helpMessage() {
//     log.info"""
//   Usage:  nextflow run main.nf --input <samples.tsv> 

//   Required Arguments:

//   --input		Specify full path and name of sample input file.

//   Optional Arguments:

//   --outdir	Specify path to output directory. 
	
// """.stripIndent()
// }

workflow {
	main:
	// // Validate correct version is used
	// if( !nextflow.version.matches('>=25.10.2') ) {
    // error "This workflow requires Nextflow version 23.10 or greater -- You are running version $nextflow.version"
	// }

	// Print pipeline information
	header()

	if ( params.help ) { 
	// if ( params.help || params.input == false ) {   
	// Invoke the help function above and exit
	// helpMessage()
	println "Help message to be printed"
	exit 1

	// If none of the above are a problem, then run the workflow
	} 
	
	else {

	// Create channel for the read files and extract the barcode from file name as the sample name
	files = channel.fromPath(params.read_files)
	.map {
		file -> tuple(get_name(file), file)
	}

	// QC: Identify % aligning to the reference (gDNA/helper phage contamination)
	minimap_out = minimap2(files, params.phagemid_ref)

	// // Convert and index the SAM file format to BAM file format
	// sam_out = samtools(minimap_out)

	// // Extract heavy and light chain pairs from the reads, and output summary stats
	// matchbox_out = matchbox(files, 
	// 			// params.matchbox_path, 
	// 			params.matchbox_antibody_preprocess_script)

	// // Annotate heavy and light chain sequences
	// riot_out = riot(matchbox_out.matchbox_files) 
	}

	// // Publish outputs
    // publish:
	// bam_file = sam_out.aligned_sorted_read
	// bam_index = sam_out.index
	// aligned_stats = sam_out.aligned_stats
	// matchbox_stats = matchbox_out.matchbox_stats
	// matchbox_files = matchbox_out.matchbox_files
	// annotated_hc = riot_out.annot_heavy
	// annotated_lc = riot_out.annot_light

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
	"""
	
	// Error message
	onError:
    log.error "Error: Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}

// // Set output paths
// output {
// 	bam_file {
//         path "1. aligned reads"
//     }
// 	bam_index {
//         path "1. aligned reads"
//     }
// 	aligned_stats {
// 		path "1. aligned reads/stats"
// 	}
// 	matchbox_stats {
// 		path "2. extracted reads/counts"
// 	}
// 	matchbox_files {
// 		path "2. extracted reads"
// 	}
// 	annotated_hc {
// 		path "3. annotated reads"
// 	}
// 	annotated_lc {
// 		path "3. annotated reads"
// 	}
}