/*
Create a counts matrix for downstream analysis.
*/

// Enable typed processes
nextflow.enable.types = true

// Create record type for sample
record Sample {
    barcode: String
    file: Path
}

process counts_matrix {
	tag "${barcode}"
    label "process_high"

	// Declare inputs required for the process
    input:
    // Record for sample name, and path for DNA sequence fastq files
	record (
        barcode: String, 
        file: Path
    )
    file_path_to_counts: Path

    output:
    // counts_matrix: Path = file("counts_matrix.csv")
    file("counts_matrix.csv")

    /*
    Run matchbox script, output only heavy and light chain reads, and statistics
    -s  Execute the matchbox script
    -e  Include error tolerance of 0.3 (30%) for insertions, deletions and substitutions
    -a  Set seqid argument as the sample name, along with target sequences for extraction of light and heavy chains from matchbox parameter csv file
    --with-reverse-complement   Also process the reverse complement of the reads over the script
    -m  Select the match parameter (all, all-best, one-best)
    */
    script:
    """
    """

    stub:
    """
    touch ${barcode}_count.csv
    """
}