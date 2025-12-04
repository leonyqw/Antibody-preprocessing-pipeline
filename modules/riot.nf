/*
Utilize riot to annotate antibody heavy and light chain DNA sequences.
E.g. provides information on sequence and germline alignment, V(D)J & C sequence and amino acid alignment, and FWR and CDR regions
*/

//Enable typed processes
nextflow.preview.types = true

process riot {
	tag "${sample_name}"

    // riot-na version 4.0.6 in use
    // Check your python version installed if container cannot be created. Required Python version >= 3.10

    // // Enable conda and install riot if conda profile is set
	// conda (params.enable_conda ? 'bioconda::riot-na=4.0.6' : null)

	// // Use Singularity container or pull from Docker container for riot-na (linux/amd64) if singularity profile is enabled
	// container "${ (workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container) ?
    // 'oras://community.wave.seqera.io/library/pip_riot-na:2f1b1af645ebb445' :
    // 'community.wave.seqera.io/library/pip_riot-na:39dc45a0992795a8' }"

	// Declare inputs required for the process
    input:
    // Tuple for sample name, and paths for heavy chain and light chain files
	(sample_name, heavy_file, light_file): Tuple<String, Path, Path>
	
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