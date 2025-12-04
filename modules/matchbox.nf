/*
Utilize matchbox to extract only the variable heavy and light chains
*/

//Enable typed processes
nextflow.preview.types = true

process matchbox {
	tag "${sample_name}"

    // Use Singularity container or pull from Docker container for samtools (linux/amd64) if singularity profile is enabled
	container 'ghcr.io/jakob-schuster/matchbox@sha256:774786ff07c5d9d16d1fb64d8329c9c2cf9fd0fe3d89856e2a2672133e0c3fae'

	// Declare inputs required for the process
    input:
    // Tuple for sample name, and path for DNA sequence fastq files
	(sample_name, read_file): Tuple<String, Path>
    matchbox_script: Path // Path to matchbox script
	
	// Declare outputs
	output:
	matchbox_stats: Path = file("${sample_name}_count.csv")
    matchbox_files = tuple(sample_name, file("${sample_name}_heavy.fasta"), file("${sample_name}_light.fasta"))

    /*
    Run matchbox script, output only heavy and light chain reads, and statistics
    -s  Execute the matchbox script
    -e  Include error tolerance of 0.3 (30%) for insertions, deletions and substitutions
    -a  Set seqid argument as the sample name
    --with-reverse-complement   Also process the reverse complement of the reads over the script
    */
    script:
    // ${matchbox_path} \\
    """
	matchbox \\
    -s ${matchbox_script} -e 0.3 \\
    -a "seqid='${sample_name}'" --with-reverse-complement\\
    ${read_file}
    """
}