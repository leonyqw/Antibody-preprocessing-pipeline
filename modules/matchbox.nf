/*
Utilize matchbox to extract only the variable heavy and light chains
*/

//Enable typed processes
nextflow.preview.types = true

process matchbox {
	tag "${sample_name}"

	// Declare inputs required for the process
    input:
    // Tuple for sample name, and path for DNA sequence fastq files
	(sample_name, read_file): Tuple<String, Path>
	// matchbox_path: Path // Path to matchbox package
    matchbox_script: Path // Path to matchbox script
	// sample_name: String // Sample name
	
	// Declare outputs
	output:
	matchbox_stats: Path = file("${sample_name}_count.csv")
    // heavy_file: Path = file("${sample_name}_heavy.fasta")
    // light_file: Path = file("${sample_name}_light.fasta")
    // sample_name: String = sample_name
    matchbox_files = tuple(sample_name, file("${sample_name}_heavy.fasta"), file("${sample_name}_light.fasta"))

    /*
    Run matchbox script, output only heavy and light chain reads, and statistics
    -s  Execute the matchbox script
    -e  Include error tolerance of 0.3 (30%) for insertions, deletions and substitutions
    -a  Set seqid argument as a string
    */
    script:
    // ${matchbox_path} \\
    """
	matchbox \\
    -s ${matchbox_script} -e 0.3 \\
    -a "seqid='${sample_name}'" \\
    ${read_file}
    """
}
//--with-reverse-complement
//Remove text and use csv