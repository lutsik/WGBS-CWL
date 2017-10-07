#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
#
#requirements:
#- $import: envvar-global.yml
#- $import: alea-docker.yml
#- class: InlineJavascriptRequirement

inputs:
  file:
    type: File
    inputBinding:
      position: 3

    doc: |
      the input fastq file
  size:
    type: int
    inputBinding:
      prefix: --lines=
      position: 1
      separate: false


    doc: |
      size of a chunck in lines
  suffix:
    type: string
    inputBinding:
      prefix: --additional-suffix=
      position: 2
      separate: false

    doc: |
      a suffix for chuncks
outputs:
  output:
    type:
      type: array
      items: File
    outputBinding:
      glob: '*$(inputs.suffix)*'
baseCommand: [split]

