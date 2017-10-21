#!/usr/bin/env cwl-runner

class: ExpressionTool
requirements:
- class: InlineJavascriptRequirement
cwlVersion: v1.0

inputs:
- id: bam_arrays
  type:
    type: array
    items:
      type: array
      items: File
#, inputBinding: { loadContents: true } }

- id: chromosomes
  type:
    type: array
    items: string

outputs:
- id: bam_arrays_per_chr
  type:
    type: array
    items:
      type: array
      items: File

- id: chrom_names
  type:
    type: array
    items: string

expression: '${

  var chroms = inputs.chromosomes; var rearranged = []; var found_chroms = []; var
  any_found = false;

  for(var ci=0; ci<chroms.length; ci++){ var chr_output = []; any_found = false; for(var
  i=0; i<inputs.bam_arrays.length; i++){ for(var j=0; j<inputs.bam_arrays[i].length;
  j++){ var this_file = inputs.bam_arrays[i][j]; if(this_file.basename.indexOf(''.''
  + chroms[ci] + ''.'') !== -1){ chr_output[chr_output.length] = this_file; any_found
  = true; } } }

  if (any_found) { rearranged[rearranged.length] = chr_output; found_chroms[found_chroms.length]
  = chroms[ci]; } } var output = {}; output[''bam_arrays_per_chr''] = rearranged;
  output[''chrom_names''] = found_chroms; return output; }'
