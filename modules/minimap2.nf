/*
Utilize minimap2 to align Oxford Nanopore DNA read sequences contained in fastq files against a reference genome database. The aligned sequence is output as a SAM file.
*/

//Enable typed processes
nextflow.preview.types = true

process minimap2 {
	tag "${sample_name}"

	// conda 'bioconda::minimap2'
	// conda (params.enable_conda ? 'bioconda::minimap2=2.30' : null)
	
	// Docker container for conda minimap2 (linux/amd64)
	// container "community.wave.seqera.io/library/minimap2:2.30--dde6b0c5fbc82ebd"

	// Singularity container for conda minimap2 (linux/amd64)
	// container "oras://community.wave.seqera.io/library/minimap2:2.30--3bf3d6cb39a98dae"

    input:
	// Tuple for sample name, and path for DNA sequence fastq files
	(sample_name, read_file): Tuple<String, Path>
	reference: Path // Path for reference genome
	
	output:
	// aligned_read: Path = file("${sample_name}_aligned.sam")
	// sample_name: String = sample_name
	minimap_out = tuple(sample_name, file("${sample_name}_aligned.sam"))

	/*
	Run minimap, mapping reads to a reference and outputs a sam file
	-a			Generates CIGAR and outputs alignments in sam format
	-x map-ont	Sets preset for ONT alignment
	-o			Output alignments to sam file
	*/
    script:
    """
	minimap2 \\
	-ax map-ont \\
	${reference} \\
	${read_file} \\
	-o "${sample_name}_aligned.sam"
    """
}