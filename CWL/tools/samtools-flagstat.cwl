#!/usr/bin/env cwl-runner

# source: GGR-cwl / peak_calling / samtools-extract-number-mapped-reads.cwl 
cwlVersion: v1.0
class: CommandLineTool
hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 10000
#  - class: DockerRequirement
#    dockerPull: 'dukegcb/samtools'

requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement

inputs:
  output_suffix:
    type: string
    default: .flagStat
  input_bam_file:
    type: File
    inputBinding:
      position: 10
    doc: Aligned BAM file to filter
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/,
        "") + inputs.output_suffix)

    doc: Samtools Flagstat report file
baseCommand: [samtools, flagstat]
stdout: $(inputs.input_bam_file.path.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/,
  "") + inputs.output_suffix)
doc: Extract mapped reads from BAM file using Samtools flagstat command

