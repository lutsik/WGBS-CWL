#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
#
requirements:
#- $import: envvar-global.yml
#- $import: alea-docker.yml
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  do_clean:
    type: boolean
    doc: |
      action switch
  data_dir:
    type: string
    doc: |
      the working directory with files
  files:
    type:
      type: array
      items: string
    doc: |
      the input files to remove
outputs:
  output:
    type:
      type: array
      items: string
    outputBinding:
      outputEval: $(inputs.files)

baseCommand: [cd]
arguments:
- valueFrom: $(inputs.data_dir)
  position: 1
- valueFrom: ;
  position: 2
  shellQuote: false
- valueFrom: "${ \n    if(inputs.do_clean){\n       return \"rm\";\n    }else{\n \
    \      return \"ls\";\n    }\n}\n"
  position: 3
- valueFrom: $(inputs.files)
  position: 100000

