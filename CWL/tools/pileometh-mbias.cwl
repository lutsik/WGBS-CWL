#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: ShellCommandRequirement

inputs:
  bam_file:
    type: File
    secondaryFiles:
    - ^.bai
    inputBinding:
      position: 5

    doc: |
      the input bam file
  reference:
# replaced file with string for efficiency in Toil        
#- id: "reference"
#  type: File
#  description: |
#    FASTA file with the reference genome
#  secondaryFiles:
#    - .fai
#  inputBinding:
#    position: 3

    type: File
    inputBinding:
      position: 4

    doc: |
      FASTA file with the reference genome
  min_mapq:
    type: int
    default: 0
    inputBinding:
      prefix: -q
      position: 100000
      separate: true

    doc: |
      min_mapq
  mbiasfile_name:
    type: string
    inputBinding:
      position: 1000000
      separate: true

    doc: "FASTA file \n"
  min_depth:
    type: int
    default: 1
    inputBinding:
      prefix: -D
      position: 100000
      separate: true


    doc: |
      min_depth
  min_phred:
    type: int
    default: 1
    inputBinding:
      prefix: -p
      position: 100000
      separate: true

    doc: |
      min_phred
outputs:
  mbias_file:
    type:
      type: array
      items: File
    outputBinding:
      glob: '*$(inputs.mbiasfile_name)*'
baseCommand: [/ngs_share/tools/PileOMeth/PileOMeth]
stdout: $(inputs.mbiasfile_name).txt
arguments:
- valueFrom: mbias
  position: 2
- valueFrom: --txt
  position: 3
  shellQuote: false

