#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: ShellCommandRequirement


inputs:
  nOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOB
      separate: true

    doc: "nOB \n"
  OT:
    type: string
    inputBinding:
      position: 100000
      prefix: --OT
      separate: true

    doc: "OT \n"
  CTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOB
      separate: true

    doc: "CTOB \n"
  min_depth:
    type: int
    default: 1
    inputBinding:
      prefix: --minDepth
      position: 100000
      separate: true

    doc: "min_depth \n"
  OB:
    type: string
    inputBinding:
      position: 100000
      prefix: --OB
      separate: true

    doc: "OB \n"
  reference:
#- id: "reference"
#  type: File
#  description: |
#    FASTA file with the reference genome
#  secondaryFiles:
#    - .fai
#  inputBinding:
#    position: 2

    type: string
    inputBinding:
      position: 2

    doc: |
      FASTA file with the reference genome
  noCG: boolean
  nOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nOT
      separate: true

    doc: "nOT \n"
  nCTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOT
      separate: true

    doc: "nCTOT \n"
  min_mapq:
    type: int
    default: 0
    inputBinding:
      prefix: -q
      position: 100000
      separate: true

    doc: "min_mapq \n"
  file_dir: string
  bam_file:
    type: string
    inputBinding:
      position: 3

    doc: |
      the input bam file
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
  nCTOB:
    type: string
    inputBinding:
      position: 100000
      prefix: --nCTOB
      separate: true


    doc: "nCTOB \n"
  CTOT:
    type: string
    inputBinding:
      position: 100000
      prefix: --CTOT
      separate: true

    doc: "CTOT \n"
outputs:
  methcall_bed:
    type: string
    outputBinding:
      glob: meth_calls
      loadContents: true
      outputEval: $(self[0].contents.split("\n")[0])

baseCommand: cd
arguments:
- valueFrom: $(inputs.file_dir)
  position: -2
- valueFrom: ;
  position: -1
- valueFrom: /ngs_share/tools/PileOMeth_dev/PileOMeth
  position: 1
- valueFrom: extract
  position: 2
- valueFrom: ${ if(inputs.noCG){ return "--noCpG"; }else{ return null; } }
  position: 10000
- valueFrom: ${ if(inputs.noCG){ return "--CHH"; }else{ return null; } }
  position: 10001
- valueFrom: ;
  position: 1000000
- valueFrom: ls
  position: 1000001
- valueFrom: '*bedGraph'
  position: 1000002
  shellQuote: false
- valueFrom: '|'
  position: 1000003
- valueFrom: grep
  position: 1000004
- valueFrom: $(inputs.bedfile_name)
  position: 1000005

stdout: meth_calls

