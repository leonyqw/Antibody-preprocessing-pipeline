#!/usr/bin/env nextflow

// Enable typed processes
nextflow.enable.types = true

// // Pipeline parameters
// params {
//     read_dir            : String
//     sample_sheet        : Path
//     phagemid_ref        : Path
//     matchbox_script     : Path
//     matchbox_parameters : Path
//     help                : Boolean
//     enable_conda        : Boolean
//     nanobody            : Boolean
// }

// Import processes or subworkflows to be run in the workflow
// include { header                } from './subworkflows/header'
// include { helpMessage           } from './subworkflows/help'
include { validate_params       } from '../modules/validate_params'
include { parse_sample_sheet    } from '../modules/local/file_import'
include { minimap2              } from '../modules/local/minimap2'
include { samtools              } from '../modules/local/samtools'
include { matchbox              } from '../modules/local/matchbox'
include { riot                  } from '../modules/local/riot'
include { matchbox as matchbox2 } from '../modules/local/matchbox'
include { riot as riot2         } from '../modules/local/riot'

workflow  ABPREP {

    take:
    read_dir            : String
    sample_sheet        : Path
    phagemid_ref        : Path
    matchbox_script     : Path
    matchbox_parameters : Path
    help                : Boolean
    enable_conda        : Boolean
    nanobody            : Boolean


    main:

    // // Validate correct nextflow version is used
    // if (!nextflow.version.matches('>=25.10.0')) {
    //     error("This workflow requires Nextflow version 25.10 or greater -- You are running version ${nextflow.version}")
    // }

    // // Print message for conda which is currently unsupported
    // if (params.enable_conda) {
    //     error("Note: The use of conda is currently unsupported")
    // }

    // // Invoke help message if required
    // helpMessage()

    // // Print pipeline information
    // header()

    // Validate parameters
    paths_to_validate = [read_dir, phagemid_ref, matchbox_script, matchbox_parameters].join(",")
    validate_params(paths_to_validate)

    sample = parse_sample_sheet(read_dir, sample_sheet)

    // QC: Identify % aligning to the reference (gDNA/helper phage contamination)
    minimap_out = minimap2(sample, phagemid_ref)

    // Convert and index the SAM file format to BAM file format
    sam_out = samtools(minimap_out)

    // Extract heavy and light chain pairs from the reads
    // Match and output all
    matchbox_out_all = matchbox(
        sample,
        matchbox_script,
        matchbox_parameters,
        "all",
        nanobody,
    )
    // Match and output only the best match
    matchbox_out_best = matchbox2(
        sample,
        matchbox_script,
        matchbox_parameters,
        "all-best",
        nanobody,
    )

    // Annotate heavy and light chain sequences
    riot_out_best = riot(matchbox_out_best.matchbox_files, nanobody)
    riot_out_all = riot2(matchbox_out_all.matchbox_files,  nanobody)

    publish:
    barcode_file         = sample
    bam_file             = sam_out.aligned_sorted_read
    bam_index            = sam_out.index
    aligned_stats        = sam_out.aligned_stats
    read_lengths         = sam_out.read_lengths
    matchbox_stats_best  = matchbox_out_best.matchbox_stats
    matchbox_files_best  = matchbox_out_best.matchbox_files
    matchbox_stats_all   = matchbox_out_all.matchbox_stats
    matchbox_files_all   = matchbox_out_all.matchbox_files
    annotated_files_best = riot_out_best.riot_files
    annotated_files_all  = riot_out_all.riot_files

    onComplete:
    log.info(
        """
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
    )

    onError:
    log.error("Error: Pipeline execution stopped with the following message: ${workflow.errorMessage}".stripIndent())
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
    read_lengths {
        path "2_aligned_reads/read_lengths"
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
    annotated_files_best {
        path "4_annotated_reads/best"
    }
    annotated_files_all {
        path "4_annotated_reads/all"
    }
}
