#!/usr/bin/env nextflow

//Enable typed processes
nextflow.enable.types = true

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
"""
}