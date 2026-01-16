/*
Import samples using a sample sheet
*/

// Enable typed processes
nextflow.preview.types = true

// ADAPTED FROM https://stackoverflow.com/questions/74039553/nextflow-rename-barcodes-and-concatenate-reads-within-barcodes

// process concat_reads {
//     tag "${sample_name}"
//     label 'process_low'
//     // publishDir "${params.output_dir}/concat_reads", mode: 'copy', failOnError: true

//     input:
//     //(sample_name, fastq_files, species, report_group): Tuple<String, Path, String, String>
//     (sample_name, fastq_files): Tuple<String, Path>

//     output:
//     sample = tuple(sample_name, file("${sample_name}.${extn}"))
//     //sample = tuple(sample_name, file("${sample_name}.${extn}"), species, report_group)

//     script:
//     if( fastq_files.every { format1 -> format1.name.endsWith('.fastq.gz') } )
//         extn = 'fastq.gz'
//     else if( fastq_files.every { format2 -> format2.name.endsWith('.fastq') } )
//         extn = 'fastq'
//     else if( fastq_files.every { format3 -> format3.name.endsWith('.fq.gz') } )
//         extn = 'fq.gz'
//     else if( fastq_files.every { format4 -> format4.name.endsWith('.fq') } )
//         extn = 'fq'
//     else
//         error "Concatentation of mixed filetypes is unsupported"

//     """
//     cat ${fastq_files} > "${sample_name}.${extn}"
//     """
// }

// process search_files {
    
// }

workflow parse_sample_sheet {
    
    take:
    fastq_dir: String
    sample_sheet: Path
    barcode_dir: Boolean
    
    main:
    // update to cover all possible fastq file extensions
    // fastq_extns = [ '.fastq', '.fastq.gz' , '.fq', '.fq.gz' ]

    samples = channel.fromPath(sample_sheet)
    .splitCsv(header: true)

    samples.view( { row -> println(row.barcode)} )

    // TO DO
    // For each row, make process to find all files that match barcode and output the file?
    // Then output each barcode file individually

    // Process takes file path and barcode
    // Channel
    // .fromPath('./data/test/*barcode01*.{fastq,fq,fastq.gz,fq.gz}')

    // For the files, may need to concat and create a new file
    // Output the files to a new folder




    // // deal with the case that fastqs are located in folders named by barcode
    // if( barcode_dir ) {
        
    //     concatenated_file_tuple = channel.fromPath(sample_sheet)
    //         .splitCsv(header: true)
    //         .map{ row ->
    //             def full_path = fastq_dir + "/" + "${row.barcode}"
    //             def all_files = file(full_path).listFiles()
    //             def fastq_files = all_files.findAll { 
    //                 fn -> fastq_extns.find { ext -> fn.name.endsWith( ext ) }
    //             }
    //             tuple(row.sample_name, fastq_files)
    //             // tuple(row.sample_name, fastq_files, row.species, row.report_group)
    //         }
    //         // .concat_reads
    // }
    // // deal with the case that files are all located in the same folder and named {something}barcode01{something}.fq.gz
    // else {
    //     println(file(fastq_dir).listFiles())

    //     // concatenated_file_tuple = 
    //     channel.fromPath(sample_sheet)
    //         .splitCsv(header: true)
    //         .map { row -> 
    //             def fastq_files = file(fastq_dir)
    //         //         .listFiles()
    //         //         .findAll {
    //         //             fn -> fn.name.startsWith( "${row.barcode}" ) && fastq_extns.find { 
    //         //             ext -> fn.name.endsWith( ext ) 
    //         //             }
    //                 }
    //         //     tuple(row.sample_name, fastq_files)
    //             // tuple(row.sample_name, fastq_files, row.species, row.report_group)
    //         }
    //         // .concat_reads
    // // }

    // emit:
    // concatenated_file_tuple
}