#!/usr/bin/env nextflow

// Enable strict syntax
//export NXF_SYNTAX_PARSER=v2

// Enable typed processes
nextflow.preview.types = true

// Pipeline parameters
params {
	read_dir: String
	sample_sheet: Path
	phagemid_ref: Path
	matchbox_script: Path
	matchbox_parameters: Path
	help: Boolean
	enable_conda: Boolean
}

// Import processes or subworkflows to be run in the workflow
include { header } from './modules/header'
include { validate_params } from './modules/validate_params'
include { parse_sample_sheet } from './modules/file_import'
include { helpMessage } from './modules/help'
include { minimap2 } from './modules/minimap2'
include { samtools } from './modules/samtools'
include { matchbox } from './modules/matchbox'
include { riot } from './modules/riot'
include { matchbox as matchbox2 } from './modules/matchbox'
include { riot as riot2 } from './modules/riot'

// Create function to get the barcode from the file name
def get_name(file) {
    return (file.baseName =~ /barcode\d+/)[0]
}

workflow {
	main:

	// Validate correct nextflow version is used
	if( !nextflow.version.matches('>=25.10.0') ) {
    error "This workflow requires Nextflow version 25.10 or greater -- You are running version $nextflow.version"
	}

	// Print message for conda which is currently unsupported
	if( params.enable_conda ) {
    error "Note: The use of conda is currently unsupported"
	}

	// Invoke help message if required
	helpMessage()
	
	// Print pipeline information
	header()

	// Validate parameters
	paths_to_validate = [params.read_dir, params.phagemid_ref, params.matchbox_script, params.matchbox_parameters].join(",")
    validate_params(paths_to_validate)

	sample = parse_sample_sheet(params.read_dir, params.sample_sheet)

	// QC: Identify % aligning to the reference (gDNA/helper phage contamination)
	minimap_out = minimap2(sample, params.phagemid_ref)

	// Convert and index the SAM file format to BAM file format
	sam_out = samtools(minimap_out)

	// Extract heavy and light chain pairs from the reads
	// Match and output all
	matchbox_out_all = matchbox(sample, params.matchbox_script, 
		params.matchbox_parameters, "all")
	// Match and output only the best match
	matchbox_out_best = matchbox2(sample, params.matchbox_script, 
		params.matchbox_parameters, "all-best")

	// Annotate heavy and light chain sequences
	riot_out_best = riot(matchbox_out_best.matchbox_files)
	riot_out_all = riot2(matchbox_out_all.matchbox_files)


	// Publish outputs
    publish:
	barcode_file = sample
	bam_file = sam_out.aligned_sorted_read
	bam_index = sam_out.index
	aligned_stats = sam_out.aligned_stats
	matchbox_stats_best = matchbox_out_best.matchbox_stats
	matchbox_files_best = matchbox_out_best.matchbox_files
	matchbox_stats_all = matchbox_out_all.matchbox_stats
	matchbox_files_all = matchbox_out_all.matchbox_files
	annotated_hc_best = riot_out_best.annot_heavy
	annotated_lc_best = riot_out_best.annot_light
	annotated_hc_all = riot_out_all.annot_heavy
	annotated_lc_all = riot_out_all.annot_light

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
	barcode_file {
        path "1_combined_reads"
    }
	bam_file {
        path "2_aligned_reads/bam_files"
    }
	bam_index {
        path "2_aligned_reads/bam_files"
    }
	aligned_stats {
		path "2_aligned_reads/stats"
	}
	matchbox_stats_best {
		path "3_extracted_reads/best/counts"
	}
	matchbox_files_best {
		path "3_extracted_reads/best/fasta_files"
	}
	matchbox_stats_all {
		path "3_extracted_reads/all/counts"
	}
	matchbox_files_all {
		path "3_extracted_reads/all/fasta_files"
	}
	annotated_hc_best {
		path "4_annotated_reads/best"
	}
	annotated_lc_best {
		path "4_annotated_reads/best"
	}
	annotated_hc_all {
		path "4_annotated_reads/all"
	}
	annotated_lc_all {
		path "4_annotated_reads/best"
	}
}