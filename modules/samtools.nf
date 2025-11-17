/*
samtools process to .
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
	aligned_read: Path
	name: String
	
	// Declare outputs
	output:
	out_file: Path = file("${name}_aligned_sorted.bam")
    //emit: aligned_sorted_read

    script:
    """
	samtools view -b "${aligned_read}" | samtools sort -o "${name}_aligned_sorted.bam"
    """
}

// 
// samtools index "${name}_aligned_sorted.bam"
// samtools flagstat "${name}_aligned_sorted.bam" > "${name}_alignment_stats.txt"