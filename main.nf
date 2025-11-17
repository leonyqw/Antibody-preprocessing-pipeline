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
	name: String = "SAMPLE_NAME"
	phagemid_ref: Path = "${projectDir}/data/reference_files/fab_phagemid.fa"
}

// Import processes or subworkflows to be run in the workflow
include { minimap2 } from './modules/minimap2'

workflow {
	// Create channel for the read files and reference genome file
	read_files = channel.fromPath(params.read_files)
	ref = channel.value(params.phagemid_ref)

	// Combine the read files with the phagemid reference
	// Do I need to include the reference, or can I use this in the process doc?
	// input_ch = read_files.combine(phagemid_ref)

// # qc: % aligning to the reference (gDNA/helper phage contamination)
	minimap2(read_files, ref, params.name)

    // publish:
    // samples = ch_samples
}

// output {
//     samples {
//         path { sample -> "fastq/${sample.id}/" }
//     }
// }

// ## DON'T CHANGE ANYTHING ELSE ##
// # ref files, scripts etc
// matchbox_path=/vast/projects/antibody_sequencing/matchbox/target/release/matchbox
// matchbox_script=/vast/projects/antibody_sequencing/PC008/antibody_preprocess.mb
// heavy_file="${name}_heavy.fasta"
// light_file="${name}_light.fasta"



// # extract with matchbox
// $matchbox_path --script-file $matchbox_script -e 0.3 --args "seqid='${name}'" $read_file > "${name}_extract_stats.txt"

// riot_na -f $heavy_file --species HOMO_SAPIENS -p 16 > "${name}_annot_heavy.csv"
// riot_na -f $light_file --species HOMO_SAPIENS -p 16 > "${name}_annot_light.csv"