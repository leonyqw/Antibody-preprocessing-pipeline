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
	// name: String = "SAMPLE_1" //May change depending on how samples are named?
	phagemid_ref: Path = "${projectDir}/data/reference_files/fab_phagemid.fa"
	matchbox_path: Path = "${projectDir}/matchbox/matchbox"
	// matchbox_path=/vast/projects/antibody_sequencing/matchbox/target/release/matchbox
	matchbox_antibody_preprocess_script: Path = "${projectDir}/matchbox/antibody_preprocess.mb"
	// matchbox_script=/vast/projects/antibody_sequencing/PC008/antibody_preprocess.mb
	// output_path: Path = "${projectDir}/output/"
}

// Import processes or subworkflows to be run in the workflow
include { minimap2 } from './modules/minimap2'
include { samtools } from './modules/samtools'
include { matchbox } from './modules/matchbox'
include { riot } from './modules/riot'

// Create function to get the barcode from the file name
def get_name(file) {
    return (file.baseName =~ /barcode\d+/)[0]
}

workflow {
	// Create channel for the read files and extract the barcode from file name as the sample name
	files = channel.fromPath(params.read_files)
	.map {
		file -> tuple(file, get_name(file))
	}

	// QC: Identify % aligning to the reference (gDNA/helper phage contamination)
	minimap2(files, params.phagemid_ref)
	// Convert and index the SAM file format to BAM file format
	samtools(minimap2.out.aligned_read, minimap2.out.sample_name)

	// Extract heavy and light chain pairs from the reads, and output summary stats
	matchbox(files, 
				// params.matchbox_path, 
				params.matchbox_antibody_preprocess_script)

	// Annotate heavy and light chain sequences
	riot(matchbox.out.heavy_file, matchbox.out.light_file, matchbox.out.sample_name) 

    // // publish:
    // samples = ch_samples
}

// output {
//     samples {
//         path { sample -> "fastq/${sample.id}/" }
//     }
// }