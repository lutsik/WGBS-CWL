#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
#
#requirements:
#- $import: envvar-global.yml
#- $import: alea-docker.yml
#- class: InlineJavascriptRequirement

inputs:
  file_dir: string
  suffix:
    type: string
    inputBinding:
      prefix: --additional-suffix=
      position: 2
      separate: false

    doc: |
      a suffix for chuncks
  file:
  #inputBinding:
  #  position: 1


    type: File
    inputBinding:
      position: 3

    doc: |
      the input log file
  size:
    type: int
    inputBinding:
      prefix: --lines=
      position: 1
      separate: false


    doc: |
      size of a chunck in lines
outputs:
  output:
    type:
      type: array
      items: File
    outputBinding:
      glob: '*$(inputs.suffix)*'
baseCommand: [cd]
arguments:
- valueFrom: $(inputs.file_dir)
  position: 1
- valueFrom: ;
  position: 2
- valueFrom: cat
  position: 100
- valueFrom: '>'
  position: 1001
- valueFrom: $(inputs.file_dir + "/" + inputs['alignment_filename']).sam
  position: 1002

