#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement

inputs:
  output_file_name: string
  input_bed_files:
    type:
      type: array

      items: File
    inputBinding:
      position: 100000
outputs:
  merged_bed_file:
    type: File
    streamable: true
    outputBinding:
      glob: $(inputs['output_file_name'])

baseCommand: [tail]
stdout: $(inputs['output_file_name'])
arguments:
- valueFrom: '+2'
  prefix: -n
  position: 1
- valueFrom: -q
  position: 2 


#  - valueFrom: |
#      ${
#          var file_list = '';
#          for(var i = 0; i < inputs.input_bed_files.length; i++){
#              file_list = file_list.concat(inputs.input_bed_files[i].path);
#              if(i < inputs.input_bed_files.length - 1){
#                 file_list = file_list.concat(' ');
#              }
#          }
#          return file_list;
#      }
#    position: 3
