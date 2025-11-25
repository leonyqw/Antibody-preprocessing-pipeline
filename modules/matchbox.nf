/*
Utilize matchbox to extract only the variable heavy and light chains
*/

//Enable typed processes
nextflow.preview.types = true

process matchbox {
	tag "${sample_name}"

	// Declare inputs required for the process
    input:
    (read_file, sample_name): Tuple<Path, String> // Path for DNA sequence fastq files
	// matchbox_path: Path // Path to matchbox package
    matchbox_script: Path // Path to matchbox script
	// sample_name: String // Sample name
	
	// Declare outputs
	output:
	matchbox_stats: Path = file("${sample_name}_count.csv")
    heavy_file: Path = file("${sample_name}_heavy.fasta")
    light_file: Path = file("${sample_name}_light.fasta")
    sample_name: String = sample_name

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