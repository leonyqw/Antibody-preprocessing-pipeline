#!/usr/bin/env nextflow

//Enable typed processes
nextflow.preview.types = true

// Print pipeline information
workflow header {

log.info """
=======================================================================================
QC preprocessing pipeline
=======================================================================================

Created by Leon Wang
Find documentation @ 
Cite this pipeline @ 

=======================================================================================
Workflow run parameters 
=======================================================================================
read directory     : ${params.read_dir}
sample sheet       : ${params.sample_sheet}
reference genome   : ${params.phagemid_ref}
matchbox script    : ${params.matchbox_script}
matchbox parameters: ${params.matchbox_parameters}
=======================================================================================
"""
}