#!/usr/bin/env cwl-runner

# Command Line:
# zcat <file> | 'head -n  <max_reads*4> | \
# split - --additional-suffix=<suffix_derived_from_filename> --lines=<size>
#
# Notes: head only executed for max_reads > 0


cwlVersion: v1.0
class: CommandLineTool
requirements:
- class: ShellCommandRequirement

hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 15000
  diskMin: 15000

inputs:
  size:
    type: int
    inputBinding:
      prefix: --lines=
      position: 205
      separate: false
      valueFrom: $(self * 4)

    doc: |
      size of a chunck in lines
  file:
    type: File
    inputBinding:
      position: 1

    doc: |
      the input fastq file
  max_reads:
    type: int
    doc: |
      take at most max_reads reads
outputs:
  output:
    type:
      type: array
      items: File
    outputBinding:
      glob: $("*" + inputs.file.basename.replace(/\.fastq.*/i,"_splitted.fastq"))

baseCommand: [zcat]
arguments:
- valueFrom: |
    ${
         if(inputs.max_reads>0){
               return "|";
         }else{
               return "";
         }
     }
  position: 100
  shellQuote: false
- valueFrom: |
    ${
         if(inputs.max_reads>0){
               return "head";
         }else{
               return "";
         }
     }
  position: 101
- valueFrom: |
    ${
         if(inputs.max_reads>0){
               return "-n";
         }else{
               return "";
         }
     }
  position: 102
  shellQuote: false
- valueFrom: |
    ${
         if(inputs.max_reads>0){
               return inputs.max_reads*4;
         }else{
               return "";
         }
     }
  position: 103
  shellQuote: false
- valueFrom: '|'
  position: 200
  shellQuote: false
- valueFrom: split
  position: 201
- valueFrom: '-'
  position: 202
  shellQuote: false
- valueFrom: $(inputs.file.basename.replace(/\.fastq.*/i,"_splitted.fastq"))
  prefix: --additional-suffix=
  position: 203
  separate: false

