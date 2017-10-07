#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: InlineJavascriptRequirement

inputs:
  inputFileName_mergedSam:
    type:
      type: array
      items: File
    inputBinding:
      position: 100

  outputFileName_mergedSam:
    type: string
    doc: 'SAM or BAM file to write merged result to Required

      '
outputs:
  mergeSam_output:
    type: File
    outputBinding:
      glob: $(inputs.outputFileName_mergedSam)
baseCommand: cat
stdout: $(inputs.outputFileName_mergedSam)

