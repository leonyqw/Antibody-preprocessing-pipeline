#!/usr/bin/env nextflow

// Enable typed processes
// nextflow.preview.types = true

// Import processes or subworkflows to be run in the workflow
include { validate_params       } from '../modules/validate_params'
include { parse_sample_sheet    } from '../modules/file_import'
include { minimap2              } from '../modules/minimap2'
include { samtools              } from '../modules/samtools'
include { matchbox              } from '../modules/matchbox'
include { riot                  } from '../modules/riot'
include { matchbox as matchbox2 } from '../modules/matchbox'
include { riot as riot2         } from '../modules/riot'

workflow ABPREP {

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
    matchbox_out_all = matchbox(
        sample,
        params.matchbox_script,
        params.matchbox_parameters,
        "all",
        params.nanobody,
    )
    // Match and output only the best match
    matchbox_out_best = matchbox2(
        sample,
        params.matchbox_script,
        params.matchbox_parameters,
        "all-best",
        params.nanobody,
    )

    // Annotate heavy and light chain sequences
    riot_out_best = riot(matchbox_out_best.matchbox_files, params.nanobody)
    riot_out_all = riot2(matchbox_out_all.matchbox_files, params.nanobody)

    emit:
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

}
