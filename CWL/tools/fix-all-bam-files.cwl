cwlVersion: v1.0
class: Workflow

requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - var new_ext = function() { var ext=inputs.bai?'.bai':inputs.csi?'.csi':'.bai';
    return inputs.input.path.split('/').slice(-1)[0]+ext; };
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement

inputs:
- id: array_of_bams
  type:
    type: array
    items: File

outputs:
- id: array_of_fixed_bams
  type:
    type: array
    items: File
  outputSource: '#fix_bams/fixBam_output'
steps:
- id: fix_bams
  run: fix-bam-file.yml
  scatter: '#fix_bams/inputBAMFile'
  in:
  - {id: inputBAMFile, source: '#array_of_bams'}
  - id: outputFileName
    source: '#array_of_bams'
    valueFrom: $(inputs.inputBAMFile.basename.substr(0,inputs.inputBAMFile.basename.lastIndexOf('.'))
      + '.fixed').bam
  out:
  - {id: fixBam_output}

