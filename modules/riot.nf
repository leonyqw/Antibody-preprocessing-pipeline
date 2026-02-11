/*
Utilize riot to annotate antibody heavy and light chain DNA sequences.
E.g. provides information on sequence and germline alignment, V(D)J & C sequence and amino acid alignment, and FWR and CDR regions.
*/

//Enable typed processes
nextflow.preview.types = true

process riot {
	tag "${barcode}"
    label "process_high"

    // Enable conda and install riot if conda profile is set
	conda (params.enable_conda ? 'bioconda::riot-na=4.0.2' : null)

	// Use Singularity container or pull from Docker container for riot-na v4.0.2 (linux/amd64) if singularity profile is enabled
	container "${ (workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container) ?
    'oras://community.wave.seqera.io/library/biopython_gcc_libxcrypt_python_pruned:96826a8c3e510274' :
    'community.wave.seqera.io/library/biopython_gcc_libxcrypt_python_pruned:c0ab77d048c45319' }"

	// Declare inputs required for the process
    input:
    // Tuple for sample name, and paths for heavy chain and light chain files
	(barcode, heavy_file, light_file): Tuple<String, Path, Path>
	
	// Declare outputs
	output:
	annot_heavy: Path = file("${barcode}_annot_heavy.csv")
    annot_light: Path = file("${barcode}_annot_light.csv")

    /*
    Run riot
    -f          Input FASTA file path
    --species   Homo sapiens species germline sequence used
    -p          Set parallel processes used to 16
    -o          Output as annotated files as a csv file
    */
    script:
    """
    riot_na -f ${heavy_file} --species HOMO_SAPIENS -p 16 -o "${barcode}_annot_heavy.csv"
    riot_na -f ${light_file} --species HOMO_SAPIENS -p 16 -o "${barcode}_annot_light.csv"
    """
}