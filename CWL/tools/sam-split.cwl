#!/usr/bin/env cwl-runner

class: CommandLineTool
requirements:
- class: InlineJavascriptRequirement
cwlVersion: v1.0

inputs:
  split_files:
    type: array
    items: string
outputs:
  lambda_bam: string
expression: ${ var index = inputs.split_files.length - 1; for(var i=0; i<inputs.split_files.length;
  i++){ if(inputs.split_files[i].indexOf('Lambda') !== -1){ index = i; } } var output
  = {}; output['lambda_bam'] = inputs.split_files[index]; return output; }

