#!/usr/bin/env cwl-runner

class: ExpressionTool
requirements:
- class: InlineJavascriptRequirement
cwlVersion: v1.0

inputs:
- id: fastq_arrays
  type:
    type: array
    items:
      type: array
      items: File

outputs:
- id: flattened_fastq_array
  type:
    type: array
    items: File

expression: '${

  var rearranged = []; for(var i=0; i<inputs.fastq_arrays.length; i++){ for(var j=0;
  j<inputs.fastq_arrays[i].length; j++){ rearranged[rearranged.length] = inputs.fastq_arrays[i][j];
  } }

  var output = {}; output[''flattened_fastq_array''] = rearranged; return output;
  }'

