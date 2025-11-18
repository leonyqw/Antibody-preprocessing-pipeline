/*
Utilize samtools to write SAM file to BAM file.
*/

//Enable typed processes
nextflow.preview.types = true

process samtools {
	tag "${name}"

		// conda 'bioconda::samtools'
	// conda (params.enable_conda ? 'bioconda::samtools=2.30' : null)
	
	// Docker container for conda samtools (linux/amd64)
	// container "community.wave.seqera.io/library/samtools:1.22.1--eccb42ff8fb55509"

	// Singularity container for conda samtools (linux/amd64)
	// container "oras://community.wave.seqera.io/library/samtools:1.22.1--9a10f06c24cdf05f"

	// Declare inputs required for the process
    input:
	aligned_read_file: Path // Path for aligned reads after minimap2
	name: String // Sample name
	
	// Declare outputs
	output:
	aligned_sorted_read: Path = file("${name}_aligned_sorted.bam")

    script:
    """
	# View and convert file from SAM to BAM format. Sort alignments and outputs the file in BAM format
	samtools view -b "${aligned_read_file}" | samtools sort -o "${name}_aligned_sorted.bam"
	
	# Index BAM file for fast random access
	samtools index "${name}_aligned_sorted.bam"
	
	# Counts the number of alignments for each FLAG type
	samtools flagstat "${name}_aligned_sorted.bam" > "${name}_alignment_stats.txt"
    """
}