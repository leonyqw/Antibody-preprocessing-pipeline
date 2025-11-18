#!/usr/bin/env nextflow

//Enable strict syntax
//export NXF_SYNTAX_PARSER=v2 //Add to config file?
//Enable typed processes
nextflow.preview.types = true

// Validate correct version is used
// if( !nextflow.version.matches('>=25.10') ) {
//     error "This workflow requires Nextflow version 23.10 or greater -- You are running version $nextflow.version"
// }

// Pipeline parameters
params {
	read_files: String = "${projectDir}/data/*.fastq"
	name: String = "SAMPLE_1"
	phagemid_ref: Path = "${projectDir}/data/reference_files/fab_phagemid.fa"
	matchbox_path: Path = "${projectDir}/matchbox/matchbox"
	// matchbox_path=/vast/projects/antibody_sequencing/matchbox/target/release/matchbox
	matchbox_antibody_preprocess_script: Path = "${projectDir}/matchbox/antibody_preprocess.mb"
	// matchbox_script=/vast/projects/antibody_sequencing/PC008/antibody_preprocess.mb
	// heavy_file: String = "${name}_heavy.fasta"
	// light_file: String = "${name}_light.fasta"
}

// Import processes or subworkflows to be run in the workflow
include { minimap2 } from './modules/minimap2'
include { samtools } from './modules/samtools'
include { matchbox } from './modules/matchbox'

workflow {
	// Create channel for the read files and reference genome file
	read_files = channel.fromPath(params.read_files)
	ref = channel.value(params.phagemid_ref)

	// Combine the read files with the phagemid reference
	// Do I need to include the reference, or can I use this in the process doc?
	// input_ch = read_files.combine(phagemid_ref)

	// QC: % aligning to the reference (gDNA/helper phage contamination)
	minimap2(read_files, ref, params.name)
	samtools(minimap2.out.aligned_read, params.name)

	// Extract with matchbox
	matchbox(read_files, 
				params.matchbox_path, 
				params.matchbox_antibody_preprocess_script,
				params.name)

    // publish:
    // samples = ch_samples
}

// output {
//     samples {
//         path { sample -> "fastq/${sample.id}/" }
//     }
// }


// riot_na -f $heavy_file --species HOMO_SAPIENS -p 16 > "${name}_annot_heavy.csv"
// riot_na -f $light_file --species HOMO_SAPIENS -p 16 > "${name}_annot_light.csv"