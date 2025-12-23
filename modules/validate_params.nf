/*
Validate parameters as valid paths.
*/

//Enable typed processes
nextflow.preview.types = true

process validate_params {

    input:
    paths_to_validate: String
	parameter: String
    
	// Validate whether paths are valid
    script:
    """
    IFS=','
	read -ra paths <<< "${paths_to_validate}"
	
	missing_paths = ()
	for path in "\${paths[@]}"; do
    if [ ! -e "\${path}" ]; then
        missing_paths += ("\${path}")
    fi
	done

	if [ \${#missing_paths[@]} -gt 0 ]; then
		echo "Error: The following paths for ${parameter} do not exist:"
		printf '  %s\n' "\${missing_paths[@]}"
		exit 1
	fi
    """
}