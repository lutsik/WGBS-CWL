#!/usr/bin/env cwl-runner
cwlVersion: v1.0
id: '#bwameth'
label: bwameth
class: CommandLineTool

requirements: []
hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 15000
#    outdirMin: 512000
#    description: "the process requires at least 15G of RAM"
inputs:
  threads:
    type: int?
    label: ''
  #streamable: false
    inputBinding:
      position: 1
      prefix: --threads
      separate: true

    doc: ''
  lib_type:
    type: string
    doc: "Library type, directional or non-directional  \n"
  alignment_filename: string
  read1:
    type: File
    label: ''
    inputBinding:
      position: 3
      separate: true
    doc: the input fastq file with the first mate
  read2:
    type: File
    label: ''
  #streamable: false
    inputBinding:
      position: 4
      separate: true
    doc: the input fastq file with the second mate
  reference:
  #required: false
    type: File
    label: ''
    secondaryFiles:
    - .bwameth.c2t
    - .bwameth.c2t.amb
    - .bwameth.c2t.ann
    - .bwameth.c2t.bwt
    - .bwameth.c2t.pac
    - .bwameth.c2t.sa
    inputBinding:
      position: 2
      prefix: --reference
      separate: true


    doc: the reference fasta file
outputs:
  alignment:
    type: File
    outputBinding:
      glob: $(inputs['alignment_filename']).sam

baseCommand:
- bwameth.py
stdout: $(inputs['alignment_filename']).sam
#stderr: $(inputs['alignment_filename']).log
arguments:
- valueFrom: ${ if(inputs.lib_type=="directional"){ return null; }else{ return "--non-directional";
    } }
  position: 200

