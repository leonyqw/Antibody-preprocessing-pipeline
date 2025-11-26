/*
Utilize riot to annotate antibody heavy and light chain DNA sequences.
E.g. provides information on sequence and germline alignment, V(D)J & C sequence and amino acid alignment, and FWR and CDR regions
*/

//Enable typed processes
nextflow.preview.types = true

process riot {
	tag "${sample_name}"

	// Declare inputs required for the process
    input:
    // Tuple for sample name, and paths for heavy chain and light chain files
	(sample_name, heavy_file, light_file): Tuple<String, Path, Path>
    // heavy_file: Path // Path for heavy chain file
    // light_file: Path // Path for light chain file
	// sample_name: String // Sample name
	
	// Declare outputs
	output:
	annot_heavy: Path = file("${sample_name}_annot_heavy.csv")
    annot_light: Path = file("${sample_name}_annot_light.csv")

    /*
    Run riot
    -f          Input FASTA file path
    --species   Homo sapiens species germline sequence used
    -p          Set parallel processes used to 16
    -o          Output as annotated files as a csv file
    */
    script:
    """
    riot_na -f ${heavy_file} --species HOMO_SAPIENS -p 16 -o "${sample_name}_annot_heavy.csv"
    riot_na -f ${light_file} --species HOMO_SAPIENS -p 16 -o "${sample_name}_annot_light.csv"
    """
}