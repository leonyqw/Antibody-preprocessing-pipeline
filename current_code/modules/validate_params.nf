/*
Validate parameters are valid paths.
*/

//Enable typed processes
nextflow.preview.types = true

process validate_params {

    input:
    paths_to_validate: String
    
	// Validate whether paths are valid
    script:
	"""
	# Read input, splits strings on comma, and stores results as "paths"
    IFS=',' read -ra paths <<< "${paths_to_validate}"

	missing_paths=()

	# Loop through and validate all parameter paths
	for path in "\${paths[@]}"; do

		# Enable nullglob so unmatched globs expand to nothing
		shopt -s nullglob
		files=(\${path})
		shopt -u nullglob

		# Check if glob matched any files
		if [ \${#files[@]} -eq 0 ]; then
			missing_paths+=("\${path}")
		fi

		# Check if files are a literal path
		for file in "\${files[@]}"; do
			if [ ! -e "\${file}" ]; then
				missing_paths+=("\${path}")
			fi
		done

	done

	# Print missing paths (if any)
	if [ \${#missing_paths[@]} -gt 0 ]; then
		echo "Error: The following paths do not exist:"
		printf '  %s\n' "\${missing_paths[@]}"
		exit 1
	fi
    """
}