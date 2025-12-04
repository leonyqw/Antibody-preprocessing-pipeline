/*
Utilize samtools to write SAM file to BAM file.
*/

//Enable typed processes
nextflow.preview.types = true

process samtools {
	tag "${sample_name}"

	// Enable conda and install samtools if conda profile is set
	conda (params.enable_conda ? 'bioconda::samtools=1.22.1' : null)

	// Use Singularity container or pull from Docker container for samtools (linux/amd64) if singularity profile is enabled
	container "${ (workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container) ?
    'oras://community.wave.seqera.io/library/samtools:1.22.1--9a10f06c24cdf05f' :
    'community.wave.seqera.io/library/samtools:1.22.1--eccb42ff8fb55509' }"

	// Declare inputs required for the process
    input:
	// Tuple for sample name, and path for aligned reads after minimap2
	(sample_name, aligned_read_file): Tuple<String, Path> 
	
	// Declare outputs
	output:
	aligned_sorted_read: Path = file("${sample_name}_aligned_sorted.bam")
	index: Path = file("${sample_name}_aligned_sorted.bam.bai")
	aligned_stats: Path = file("${sample_name}_alignment_stats.tsv")

    script:
    """
	# View and convert file from SAM to BAM format. Sort alignments and outputs the file in BAM format
	samtools view -b "${aligned_read_file}" | samtools sort -o "${sample_name}_aligned_sorted.bam"
	
	# Index BAM file for fast random access
	samtools index "${sample_name}_aligned_sorted.bam"
	
	# Counts the number of alignments for each FLAG type
	samtools flagstat -O tsv "${sample_name}_aligned_sorted.bam" > "${sample_name}_alignment_stats.tsv"
    """
}