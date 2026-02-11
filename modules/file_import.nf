/*
Import samples using a sample sheet
*/

// Enable typed processes
nextflow.preview.types = true

// ADAPTED FROM https://stackoverflow.com/questions/74039553/nextflow-rename-barcodes-and-concatenate-reads-within-barcodes

process concat_reads {
    tag "${barcode}"

    input:
    (barcode, files): Tuple<String, List<Path>> // Tuple for sample barcode, and list of files with the barcode

    // Output sample: tuple containing barcode and merged file
    output:
    sample = tuple(barcode, file("${barcode}_merged.fastq"))

    script:
    // Check if all files are the same format, or if files are not found
    if( files.size() == 0 )
        error "No files found for ${barcode}"
    else if( files.every { format1 -> format1.name.endsWith('.fastq.gz') } )
        extn = 'fastq.gz'
    else if( files.every { format2 -> format2.name.endsWith('.fastq') } )
        extn = 'fastq'
    else if( files.every { format3 -> format3.name.endsWith('.fq.gz') } )
        extn = 'fq.gz'
    else if( files.every { format4 -> format4.name.endsWith('.fq') } )
        extn = 'fq'
    else
        error "Concatentation of mixed filetypes is unsupported"

    // Append and join together files from the same barcode, and output a merged file
    """
    zcat -f ${files.join(' ')} > "${barcode}_merged.fastq"
    """
}

workflow parse_sample_sheet {
    
    take:
    read_dir: String // Directory where reads are stored
    sample_sheet: Path // Path to sample sheet
    
    main:
    // Parse list of barcodes in the sample sheet
    barcodes = channel.fromPath(sample_sheet)
    .splitCsv(header: true)
    .map { row -> row.barcode }

    // Get list of files for each barcode from the read directory, as well as any files in subdirectories that match
    barcode_files = barcodes
    .map { barcode ->
        tuple(barcode, files("${read_dir}/{*,**/*}${barcode}*.{fastq,fq,fastq.gz,fq.gz}"))
    }

    // Read and concat (if multiple files) into one file per sample / barcode
    sample = concat_reads(barcode_files)

	// Declare outputs
    emit:
    sample
}