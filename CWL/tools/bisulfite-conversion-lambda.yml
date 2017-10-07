#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement

inputs:
  output_file_name: string
  input_bed_file:
    type: File
    inputBinding:
      position: 100000
outputs:
  bisulfite_conversion_file:
    type: File
    streamable: true
    outputBinding:
      glob: $(inputs['output_file_name'])

baseCommand: [awk]
stdout: $(inputs['output_file_name'])
arguments:
 # - valueFrom: "{SUM1 += $4/100; SUM2 +=1} END {print 1-SUM1/SUM2}"
  - valueFrom: ${ return "{SUM1 += $4/100; SUM2 +=1} END {print 1-SUM1/SUM2}" }
    position: 3
    shellQuote: false
#  - valueFrom:  " {print 1-SUM1/SUM2}"
#    position: 4
#    shellQuote: true
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


#cat ${SAMPLENAME}.cap.lambda.methylation_results.txt |
#awk '{SUM1 += $2; SUM2 +=$3}  END {print 1-SUM1/SUM2}' > ${SAMPLENAME}.cap.lambda.conversionrate.txt

