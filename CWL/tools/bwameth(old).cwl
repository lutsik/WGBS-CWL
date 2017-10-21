#!/usr/bin/env cwl-runner
cwlVersion: v1.0
id: '#bwameth'
label: bwameth
class: CommandLineTool

requirements:
- class: ShellCommandRequirement

hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 28000
#    outdirMin: 512000
#    description: "the process requires at least 15G of RAM"
inputs:
  read2:
    type:
    - string
    label: ''
  #streamable: false
    inputBinding:
      position: 104
      separate: true
    doc: the input fastq file with the second mate
  alignment_filename: string
  reference:
    type: File
    label: ''
    inputBinding:
      position: 102
      prefix: --reference
      valueFrom: $(self.path.replace(/\.fa/i,"" ))
      separate: true

    doc: the reference fasta file location
  lib_type:
    type: string
    doc: "Library type, directional or non-directional    \n"
  file_dir: string
  threads:
  #inputBinding:
  #  position: 1
    type: int?
    label: ''
  #streamable: false
    inputBinding:
      position: 101
      prefix: --threads
      separate: true

    doc: ''
  read1:
    type:
    - string
    label: ''
    inputBinding:
      position: 103
      separate: true
    doc: the input fastq file with the first mate
outputs:
  alignment:
    type: string
  #streamable: true
    outputBinding:
      outputEval: ${return inputs.file_dir + "/" + inputs['alignment_filename'] +
        ".sam";}
baseCommand: cd
arguments:
- valueFrom: $(inputs.file_dir)
  position: 1
- valueFrom: ;
  position: 2
- valueFrom: bwameth.py
  position: 100
- valueFrom: ${ if(inputs.lib_type=="directional"){ return null; }else{ return "--non-directional";
    } }
  position: 200
- valueFrom: '>'
  position: 1001
- valueFrom: $(inputs.file_dir + "/" + inputs['alignment_filename']).sam
  position: 1002

#stdout: $(inputs.file_dir + "/" + inputs['alignment_filename']).sam
#stderr: $(inputs['alignment_filename']).log

