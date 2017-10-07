#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#
  adms: http://www.w3.org/ns/adms#
  dcat: http://www.w3.org/ns/dcat#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#
- http://www.w3.org/ns/adms#
- http://www.w3.org/ns/dcat.rdf

cwlVersion: v1.0
class: CommandLineTool

adms:includedAsset:
  doap:name: picard
  doap:description: A set of Java command line tools for manipulating high-throughput
    sequencing data (HTS) data and formats. Picard is implemented using the HTSJDK
    Java library HTSJDK, supporting accessing of common file formats, such as SAM
    and VCF, used for high-throughput sequencing data. http://broadinstitute.github.io/picard/command-line-overview.html#BuildBamIndex
  doap:homepage: http://broadinstitute.github.io/picard/
  doap:repository:
  - class: doap:GitRepository
    doap:location: https://github.com/broadinstitute/picard.git
  doap:release:
  - class: doap:Version
    doap:revision: '1.141'
  doap:license: MIT, Apache2
  doap:category: commandline tool
  doap:programming-language: JAVA
  doap:developer:
  - class: foaf:Organization
    foaf:name: Broad Institute
doap:name: picard-InsertSizeMetric.cwl
dcat:downloadURL: https://github.com/common-workflow-language/workflows/blob/master/tools/picard-MarkDuplicates.cwl
dct:creator:
- class: foaf:Organization
  foaf:name: DKFZ
  foaf:member:
  - class: foaf:Person
    id: p.lutsik@dkfz.de
    foaf:mbox: mailto:p.lutsik@dkfz.de
doap:maintainer:
- class: foaf:Organization
  foaf:name: DKFZ
  foaf:member:
  - class: foaf:Person
    id: p.lutsik@dkfz.de
    foaf:name: Pavlo Lutsik
    foaf:mbox: mailto:p.lutsik@dkfz.de
requirements:
#- $import: envvar-global.yml
#- $import: picard-docker.yml
  - class: InlineJavascriptRequirement


hints:
- class: ResourceRequirement
  coresMin: 1
  ramMin: 10000


inputs:
  histogramWidth:
    type: int?
    inputBinding:
      position: 8
      prefix: HISTOGRAM_WIDTH=
    doc: Explicitly sets the Histogram width, overriding automatic truncation of Histogram
      tail. Also, when calculating mean and standard deviation, only bins less or
      equal Histogram_WIDTH will be included. Default value null.
  metricAccumulationLevel:
    type: string?
    inputBinding:
      position: 10
      prefix: METRIC_ACCUMULATION_LEVEL =
    doc: The level(s) at which to accumulate metrics. Default value ALL_READS. This
      option can be set to 'null' to clear the default value. Possible values ALL_READS,
      SAMPLE, LIBRARY, READ_GROUP This option may be specified 0 or more times. This
      option can be set to 'null' to clear the default list.
  deviations:
    type: double?
    inputBinding:
      position: 9
      prefix: DEVIATIONS=
    doc: Generate mean, sd and plots by trimming the data down to MEDIAN + DEVIATIONS*MEDIAN_ABSOLUTE_DEVIATION.
      This is done because insert size data typically includes enough anomalous values
      from chimeras and other artifacts to make the mean and sd grossly misleading
      regarding the real distribution. Default value 10.0. This option can be set
      to 'null' to clear the default value.
  readSorted:
    type: boolean?
    inputBinding:
      position: 22
      prefix: ASSUME_SORTED=
    doc: If true, assume that the input file is coordinate sorted even if the header
      says otherwise. Default value false. This option can be set to 'null' to clear
      the default value. Possible values {true, false}
  minPCT:
    type: double?
    inputBinding:
      position: 9
      prefix: MINIMUM_PCT=
    doc: When generating the Histogram, discard any data categories (out of FR, TANDEM,
      RF) that have fewer than this percentage of overall reads. (Range 0 to 1). Default
      value 0.05. This option can be set to 'null' to clear the default value.
  includeDuplicates:
    type: string?
    inputBinding:
      position: 7
      prefix: INCLUDE_DUPLICATES=
      separate: false

    doc: If true do not write duplicates to the output file instead of writing them
      with appropriate flags set. Default value false. This option can be set to 'null'
      to clear the default value. Possible values {true, false}
  stopAfter:
    type: long?
    inputBinding:
      position: 8
      prefix: STOP_AFTER=
    doc: Stop after processing N reads, mainly for debugging. Default value 0. This
      option can be set to 'null' to clear the default value.
  inputFileName_insertSize:
    type: File
    inputBinding:
      position: 4
      prefix: INPUT=
    doc: One or more input SAM or BAM files to analyze. Must be coordinate sorted.
      Default value null. This option may be specified 0 or more times
  histogramFile:
    type: string?
    inputBinding:
      position: 6
      prefix: HISTOGRAM_FILE=
    doc: File to write duplication metrics to Required
  java_arg:
    type: string
    default: -Xmx4g
    inputBinding:
      position: 1

  outputFileName_insertSize:
    type: string
    inputBinding:
      position: 5
      prefix: OUTPUT=
    doc: The output file to write marked records to Required
outputs:
  insertSize_output:
    type: File
    outputBinding:
      glob: $(inputs.outputFileName_insertSize)

baseCommand: [java]
arguments:
- valueFrom: /ngs_share/tools/miniconda3/envs/py27/share/picard-2.5.0-1/picard.jar
  position: 2
  prefix: -jar
- valueFrom: CollectInsertSizeMetrics
  position: 3
doc: |
  picard-CollectInsertSizeMetrics.cwl is developed for CWL consortium
   Collect metrics about the insert size distribution of a paired-end library.

