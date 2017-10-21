#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: ShellCommandRequirement

inputs:
  OB:
    type: string
    inputBinding:
      position: 100000
      prefix: --OB
      separate: true

    doc: "OB \n"
  CTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOB
      separate: true

    doc: "CTOB \n"
  OT:
    type: string
    inputBinding:
      position: 100000
      prefix: --OT
      separate: true

    doc: "OT \n"
  CTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOT
      separate: true

    doc: "CTOT \n"
  nCTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOB
      separate: true

    doc: "nCTOB \n"
  nOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOB
      separate: true

    doc: "nOB \n"
  nCTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOT
      separate: true

    doc: "nCTOT \n"
  nOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOT
      separate: true

    doc: "nOT \n"
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
  mbiasfile_name:
    type: string
    inputBinding:
      position: 1000000
      separate: true

    doc: "FASTA file \n"
outputs:
  mbias_file:
    type:
      type: array
      items: File
    outputBinding:
      glob: '*$(inputs.mbiasfile_name)*'
baseCommand: [/ngs_share/tools/MethylDackel_dev/MethylDackel]
stdout: $(inputs.mbiasfile_name).txt
arguments:
- valueFrom: mbias
  position: 2
- valueFrom: --txt
  position: 3
  shellQuote: false

