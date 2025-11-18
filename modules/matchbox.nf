/*
Utilize matchbox to extract heavy and light chains
*/

//Enable typed processes
nextflow.preview.types = true

process matchbox {
	tag "${name}"

	// Declare inputs required for the process
    input:
    read_file: Path // Path for DNA sequence fastq files
	matchbox_path: Path // Path to matchbox package
    matchbox_script: Path // Path to matchbox script
	name: String // Sample name
	
	// Declare outputs
	output:
	matchbox_stats: Path = file("${name}_extract_stats.txt")

    /*
    Run matchbox script, output heavy and light chain reads, and statistics
    -s  Execute the matchbox script
    -e  Include error tolerance of 0.3 for insertions, deletions and substitutions
    -a  Set seqid argument as a string
    */
    script:
    """
	${matchbox_path} \\
    -s ${matchbox_script} -e 0.3 \\
    -a "seqid='${name}'" \\
    ${read_file} > "${name}_extract_stats.txt"
    """
}