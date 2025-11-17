/*
Process utilizing minimap2 to align the Oxford Nanopore DNA read sequences contained in fastq files against a reference genome database.
The aligned sequence is output as a sam file.
*/

//Enable typed processes
nextflow.preview.types = true

process minimap2 {
	tag "${name}"

	// conda 'bioconda::minimap2'
	// conda (params.enable_conda ? 'bioconda::minimap2=2.30' : null)
	
	// Docker container for conda minimap2 (linux/amd64)
	// container "community.wave.seqera.io/library/minimap2:2.30--dde6b0c5fbc82ebd"

	// Singularity container for conda minimap2 (linux/amd64)
	// container "oras://community.wave.seqera.io/library/minimap2:2.30--3bf3d6cb39a98dae"

    input:
	read: Path // Path for DNA sequence fastq files
	reference: Path // Path for reference genome
	name: String // List of sample names
	
	output:
	out_file: Path = file("${name}_aligned.sam")
    //emit: aligned_read

	// Run minimap2
	// map oxford nanopore reads to a reference and output as a sam file
	// -a Generate CIGAR and output alignments in the SAM format
	// -x map-ont Sets preset for ONT alignment
	// -o output alignments to sam file
    script:
    """
	minimap2 \\
	-ax map-ont \\
	${reference} \\
	${read} \\
	-o "${name}_aligned.sam"
    """
}