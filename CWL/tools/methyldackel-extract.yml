#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: ShellCommandRequirement


inputs:
  OT:
    type: string
    inputBinding:
      position: 100000
      prefix: --OT
      separate: true

    doc: "OT \n"
  noCG: boolean
  OB:
    type: string
    inputBinding:
      position: 100000
      prefix: --OB
      separate: true

    doc: "OB \n"
  nOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOB
      separate: true

    doc: "nOB \n"
  min_phred:
    type: int
    default: 1
    inputBinding:
      prefix: -p
      position: 100000
      separate: true

    doc: "min_phred \n"
  bedfile_name:
    type: string
    inputBinding:
      position: 3
      prefix: -o
      separate: true

    doc: "FASTA file \n"
  bam_file:
    type: File
    inputBinding:
      position: 3

    doc: |
      the input bam file
  CTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOB
      separate: true

    doc: "CTOB \n"
  nCTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOT
      separate: true

    doc: "nCTOT \n"
  CTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOT
      separate: true

    doc: "CTOT \n"
  reference:
#- id: "reference"
#  type: File
#  description: |
#    FASTA file with the reference genome
#  secondaryFiles:
#    - .fai
#  inputBinding:
#    position: 2

    type: File
    inputBinding:
      position: 2

    doc: |
      FASTA file with the reference genome
  min_depth:
    type: int
    default: 1
    inputBinding:
      prefix: --minDepth
      position: 100000
      separate: true

    doc: "min_depth \n"
  min_mapq:
    type: int
    default: 0
    inputBinding:
      prefix: -q
      position: 100000
      separate: true

    doc: "min_mapq \n"
  nCTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOB
      separate: true


    doc: "nCTOB \n"
  nOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOT
      separate: true

    doc: "nOT \n"
outputs:
  methcall_bed:
    type: File
    outputBinding:
      glob: $("*" + inputs.bedfile_name + "*")

baseCommand: /ngs_share/tools/MethylDackel_dev/MethylDackel
arguments:
- valueFrom: extract
  position: 2
- valueFrom: ${ if(inputs.noCG){ return "--noCpG"; }else{ return null; } }
  position: 10000
- valueFrom: ${ if(inputs.noCG){ return "--CHH"; }else{ return null; } }
  position: 10001

