cwlVersion: v1.0
class: CommandLineTool

hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 10000

inputs:
  inputBAMFile:
    type: File
    inputBinding:
      position: 4

    doc: One or more input SAM or BAM files to fix
  java_arg:
    type: string
    default: -Xmx4g
    inputBinding:
      position: 1

  outputFileName:
    type: string
    inputBinding:
      position: 5

outputs:
  fixBam_output:
    type: File
    outputBinding:
      glob: $(inputs.outputFileName)

baseCommand: [java]
arguments:
- valueFrom: /ngs_share/tools/htsjdk/build/libs/htsjdk-2.7.0-3-g1c66107-SNAPSHOT-all.jar
  position: 2
  prefix: -cp
- valueFrom: htsjdk.samtools.FixBAMFile
  position: 3

