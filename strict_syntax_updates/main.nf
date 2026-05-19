#!/usr/bin/env nextflow

// Enable typed processes
nextflow.enable.types = true

// Import processes or subworkflows to be run in the workflow
include { header                    } from './subworkflows/header'
include { helpMessage               } from './subworkflows/help'
// include { ABPREP       } from './workflows/abprep'
include { VALIDATE_PARAMS           } from './modules/local/validate_params'
include { PARSE_SAMPLE_SHEET        } from './modules/local/file_import'
include { MINIMAP2                  } from './modules/local/minimap2'
include { SAMTOOLS                  } from './modules/local/samtools'
include { MATCHBOX as MATCHBOX_ALL  } from './modules/local/matchbox'
include { RIOT as RIOT_ALL          } from './modules/local/riot'
include { MATCHBOX as MATCHBOX_BEST } from './modules/local/matchbox'
include { RIOT as RIOT_BEST         } from './modules/local/riot'

// Pipeline parameters
params {
    read_dir: String
    sample_sheet: String
    phagemid_ref: Path
    matchbox_script: Path
    matchbox_parameters: Path
    help: Boolean
    enable_conda: Boolean
    nanobody: Boolean
}

workflow {

    main:

    // Validate correct nextflow version is used
    if (!nextflow.version.matches('>=26.04.0')) {
        error("This workflow requires Nextflow version 26.04 or greater -- You are running version ${nextflow.version}")
    }

    // Print message for conda which is currently unsupported
    if (params.enable_conda) {
        error("Note: The use of conda is currently unsupported")
    }

    // Invoke help message if required
    helpMessage()

    // Print pipeline information
    header()

    // Run AbPreP workflow
    // ABPREP()

    // Validate parameters
    paths_to_validate = [params.read_dir, params.phagemid_ref, params.matchbox_script, params.matchbox_parameters].join(",")
    VALIDATE_PARAMS(paths_to_validate)

    sample = PARSE_SAMPLE_SHEET(params.read_dir, params.sample_sheet)

    // QC: Identify % aligning to the reference (gDNA/helper phage contamination)
    minimap_out = MINIMAP2(sample, params.phagemid_ref)

    // Convert and index the SAM file format to BAM file format
    sam_out = SAMTOOLS(minimap_out)

    // Extract heavy and light chain pairs from the reads
    // Match and output all
    matchbox_out_all = MATCHBOX_ALL(
        sample,
        params.matchbox_script,
        params.matchbox_parameters,
        "all",
        params.nanobody,
    )
    // Match and output only the best match
    matchbox_out_best = MATCHBOX_BEST(
        sample,
        params.matchbox_script,
        params.matchbox_parameters,
        "all-best",
        params.nanobody,
    )

    // // Annotate heavy and light chain sequences
    // riot_out_best = RIOT_BEST(matchbox_out_best.matchbox_files, params.nanobody)
    // riot_out_all = RIOT_ALL(matchbox_out_all.matchbox_files, params.nanobody)

    // publish:
    // barcode_file         = sample
    // bam_file             = sam_out.aligned_sorted_read
    // bam_index            = sam_out.index
    // aligned_stats        = sam_out.aligned_stats
    // read_lengths         = sam_out.read_lengths
    // matchbox_stats_best  = matchbox_out_best.matchbox_stats
    // matchbox_files_best  = matchbox_out_best.matchbox_files
    // matchbox_stats_all   = matchbox_out_all.matchbox_stats
    // matchbox_files_all   = matchbox_out_all.matchbox_files
    // annotated_files_best = riot_out_best.riot_files
    // annotated_files_all  = riot_out_all.riot_files

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
// output {
//     barcode_file {
//         path "1_combined_reads"
//     }
//     bam_file {
//         path "2_aligned_reads/bam_files"
//     }
//     bam_index {
//         path "2_aligned_reads/bam_files"
//     }
//     aligned_stats {
//         path "2_aligned_reads/stats"
//     }
//     read_lengths {
//         path "2_aligned_reads/read_lengths"
//     }
//     matchbox_stats_best {
//         path "3_extracted_reads/best/counts"
//     }
//     matchbox_files_best {
//         path "3_extracted_reads/best/fasta_files"
//     }
//     matchbox_stats_all {
//         path "3_extracted_reads/all/counts"
//     }
//     matchbox_files_all {
//         path "3_extracted_reads/all/fasta_files"
//     }
//     annotated_files_best {
//         path "4_annotated_reads/best"
//     }
//     annotated_files_all {
//         path "4_annotated_reads/all"
//     }
// }
