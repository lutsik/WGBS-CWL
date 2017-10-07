#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
#sbg:homepage: https://github.com/pezmaster31/bamtools/wiki
#sbg:validationErrors: []
#sbg:sbgMaintained: false
#sbg:latestRevision: 10
#sbg:job:
#  inputs:
#    input_bam_file:
#      class: File
#      secondaryFiles: []
#      size: 0
#      path: input/test.input_bam.ext
#    ref_prefix: refp
#    tag_prefix: tagp
#    split_options: reference
#    tag: tag
#  allocatedResources:
#    cpu: 1
#    mem: 1000
#sbg:toolAuthor: Derek Barnett, Erik Garrison, Gabor Marth, and Michael Stromberg
#sbg:createdOn: 1452859175
#sbg:categories:
#- SAM/BAM-Processing
#sbg:contributors:
#- admin
#- sevenbridges-gce
#sbg:links:
#- label: Homepage
#  id: https://github.com/pezmaster31/bamtools
#- label: Wiki
#  id: https://github.com/pezmaster31/bamtools/wiki
#sbg:project: admin/sbg-public-data
#sbg:createdBy: sevenbridges-gce
#sbg:toolkitVersion: 2.4.0
#sbg:id: https://gcp-api.sbgenomics.com/v2/apps/admin/sbg-public-data/bamtools-split-2-4-0/10/raw/
#sbg:license: The MIT License
#sbg:revision: 10
#sbg:cmdPreview: /opt/bamtools/bin/bamtools split -in input/test.input_bam.ext -stub
#  test.input_bam.splitted  -reference -refPrefix refp
#sbg:modifiedOn: 1472050550
#sbg:modifiedBy: admin
#sbg:revisionsInfo:
#- #sbg:revision: 0
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1452859175
  #sbg:modifiedBy: sevenbridges-gce
#- #sbg:revision: 1
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1452859176
  #sbg:modifiedBy: sevenbridges-gce
#- #sbg:revision: 2
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- #sbg:revision: 3
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- #sbg:revision: 4
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 5
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 6
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 7
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 8
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 9
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#- sbg:revision: 10
  #sbg:revisionNotes: ~
  #sbg:modifiedOn: 1472050550
  #sbg:modifiedBy: admin
#sbg:toolkit: BamTools
#id: https://gcp-api.sbgenomics.com/v2/apps/admin/sbg-public-data/bamtools-split-2-4-0/10/raw/
inputs:
  input_bam_file:
    type:
    - File
    label: Input BAM file
    streamable: false
    #sbg:cmdInclude: true
  #sbg:category: Input & Output
  #sbg:fileTypes: BAM
  #required: true
    inputBinding:
      position: 2
      prefix: -in
      separate: true
    doc: The input BAM file.
  tag:
    type: string?
    label: Tag split
    streamable: false
    doc: Splits alignments based on all values of TAG encountered (i.e. -tag RG creates
      a BAM file for each read group in original BAM file).
  split_options:
  #sbg:category: Split Options
  #required: false
    type:
    - name: split_options
      symbols:
      - mapped
      - paired
      - reference
      - tag
      type: enum
    label: Split Options
    streamable: false
    doc: 'Property upon which the BAM splitting is performed. Warning: Splitting  by
      tags or reference can output a large number of files.'
  ref_prefix:
    type: string?
    label: Reference prefix
    streamable: false
  #sbg:category: Input & Output
  #required: false
    inputBinding:
      position: 4
      prefix: -refPrefix
    doc: Custom prefix for splitting by references. Currently files end with REF_<refName>.bam.
      This option allows you to replace "REF_" with a prefix of your choosing.
  tag_prefix:
    type: string?
    label: Tag prefix
    streamable: false
  #sbg:category: Input & Output
  #required: false
    inputBinding:
      position: 4
      prefix: ''
    doc: Custom prefix for splitting by tags. Current files end with TAG_<tagname>_<tagvalue>.bam.
      This option allows you to replace "TAG_" with a prefix of your choosing.
outputs:
  output_bam_files:
    type:
    - File[]
    label: Output BAM files
    streamable: false
    outputBinding:
      glob: |
        ${
          var filepath = inputs.input_bam_file.path;
          var file_path_sep = filepath.split("/");
          var filename = file_path_sep[file_path_sep.length-1];
          var file_dot_sep = filename.split(".bam");
          var base_name = file_dot_sep.slice(0,1);
          return base_name + ".*.bam";
        }
  #sbg:fileTypes: BAM
    doc: Output BAM files.
label: BamToolsSplit
arguments:
- valueFrom: |
    ${
       var filepath = inputs.input_bam_file.path;

       var file_path_sep = filepath.split("/");
       var filename = file_path_sep[file_path_sep.length-1];

       var file_dot_sep = filename.split(".");
       var base_name = file_dot_sep.slice(0,-1).join(".");

       return base_name;
    }
  prefix: -stub
  position: 3
- valueFrom: "${\n  var line = \"\";\n  \n  if (inputs.split_options == 'mapped'){\n\
    \    line = line.concat(\"-mapped\");\n  } else if (inputs.split_options == 'paired'){\n\
    \    line = line.concat(\"-paired\");\n  } else if (inputs.split_options == 'reference'){\n\
    \    line = line.concat(\"-reference\");\n  } else if (inputs.split_options ==\
    \ 'tag'){\n      line = line.concat(\"-tag \");\n      line = line.concat(inputs.tag)\n\
    \      if (inputs.tag_prefix){\n          line = line.concat(\" -tagPrefix \"\
    );\n          line = line.concat(inputs.tag_prefix);\n      }\n  }\n  return line;\n\
    }\n"
  position: 4
  separate: true
stdin: ''
stdout: ''
successCodes: []
temporaryFailCodes: []
baseCommand: [bamtools, split]
doc: |-
  BamTools Split splits a BAM file based on a user-specified property. It creates a new BAM output file for each value found.

  **Warning:** Splitting  by tags or reference can output a large number of files.

  **Common issues:** Splitting by tag can produce no output if the selected tag doesn't exist in the BAM file.

