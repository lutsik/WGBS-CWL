cwlVersion: v1.0
#cwlVersion: "v1.0"

class: Workflow

requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - var new_ext = function() { var ext=inputs.bai?'.bai':inputs.csi?'.csi':'.bai';
    return inputs.input.path.split('/').slice(-1)[0]+ext; };
  - var prepend = function(array,prefix) {  var file_array = []; for(var i=0; i<array.length;
    i++){ file_array[i] = prefix + '/' + array[i]; } return file_array; };
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
- id: analysis_dir
  type: string
- id: inp_read1
  type:
    type: array
    items: File
- id: inp_read2
  type:
    type: array
    items: File
- id: fastq_batch_size
  type: int
- id: reference_fasta
  type: File
  secondaryFiles:
  - .bwameth.c2t
  - .bwameth.c2t.amb
  - .bwameth.c2t.ann
  - .bwameth.c2t.bwt
  - .bwameth.c2t.pac
  - .bwameth.c2t.sa
  - .fai
    #! maybe insert secondary files
- id: max_reads
  type: int
- id: chromosomes
  type:
    type: array
    items: string
- id: chr_prefix
  type: string
- id: lib_type
  type: string
- id: trimmomatic_adapters_file
  type: File
- id: illuminaclip
  type: string
- id: trimmomatic_phred
  type: string
- id: trimmomatic_leading
  type: int
- id: trimmomatic_trailing
  type: int
- id: trimmomatic_crop
  type: int
- id: trimmomatic_headcrop
  type: int
- id: trimmomatic_tailcrop
  type: int
- id: trimmomatic_minlen
  type: int
- id: trimmomatic_avgqual
  type: int
- id: pileometh_min_phred
  type: int
- id: pileometh_min_depth
  type: int
- id: pileometh_min_mapq
  type: int
- id: pileometh_ot
  type: string
- id: pileometh_ob
  type: string
- id: pileometh_ctot
  type: string
- id: pileometh_ctob
  type: string
- id: pileometh_not
  type: string
- id: pileometh_nob
  type: string
- id: pileometh_nctot
  type: string
- id: pileometh_nctob
  type: string
- id: temp_dir
  type: string
- id: trimmomatic_jar_file
  type: File
- id: clean_raw_fastqs
  type: boolean
- id: clean_trimmed_fastqs
  type: boolean
- id: clean_primary_sams
  type: boolean
- id: clean_primary_bams
  type: boolean
- id: clean_chr_bams
  type: boolean
- id: clean_merged_bams
  type: boolean
- id: clean_dup_rm_bams
  type: boolean
#  - id: test_bam
#    type: File
#  - id: slidingw
#    type: string
#    default: "30"
#  - id: minl
#    type: int
#    default: 20

outputs:
#  - id: sequence_files_read1
#    type: 
#      type: array
#      items: Any
#    #source: "#split_read1_files/output"
#    source: "#adaptor_trimming/output_read1_trimmed_file"
#      
#  - id: sequence_files_read2
#    type: 
#      type: array
#      items: Any
#    #source: "#split_read2_files/output"
#    source: "#adaptor_trimming/output_read2_trimmed_paired_file"
#  
  - id: trimming_report
    type:
      type: array
      items: ['null', File]
    outputSource: '#adaptor_trimming/output_log_file'
  
#      
#  - id: alignment
#    type: 
#      type: array
#      items: File
#    source: "#alignment/alignment"
#    
  - id: alignment_flagstat
    type:
      type: array
      items: File
    outputSource: '#flag_stat_aligned/output'
  
#    
##  - id: merged_bam
##    type: File
##    source: "#bam_merging/mergeSam_output"
#  
#  - id: indexed_bam
#    type: 
#      type: array
#      items: File
#    source: "#index_bam_file/index"
#  
#  - id: duplicate_removed
#    type: 
#      type: array
#      items: File
#    source: "#duplicates_removal/markDups_output"
# 
  - id: duplicate_removed_flagstat
    type:
      type: array
      items: File
    outputSource: '#flag_stat_dup_removed/output'
  
#      
  - id: insert_size_metrics
    type:
      type: array
      items: File
    outputSource: '#insert_size_dist/insertSize_output'
  - id: mbias_file
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: '#mbias_calculation/mbias_file'
  - id: mbias_file_trimmed
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: '#mbias_calculation_trimmed/mbias_file'
  
#      
#  - id: converted_bam
#    type: 
#      type: array
#      items: File
#    source: "#sam_to_bam/output"
#              
#  - id: split_by_chromosome
#    type:
#      type: array
#      items: 
#        type: array
#        items: File
#    source: "#split_by_chromosome/output_bam_files"
#    
#  - id: fixed_bams
#    type: 
#      type: array
#      items: 
#        type: array
#        items: File
#    source: "#fix_all_bams/array_of_fixed_bams"
#    
#  - id: rearranged_bams
#    type: 
#      type: array
#      items: 
#        type: array
#        items: File
#    source: "#rearrange_bams/bam_arrays_per_chr"

#  - id: merged_bam
#    type: 
#      type: array
#      items: string
#    source: "#bam_merging/mergeSam_output"

#  - id: methylation_calls_simple
#    type:
#      type: array
#      items: string 
#    source: "#methylation_calling/methcall_bed"

  - id: methylation_calls
    type: File
    outputSource: '#merge_meth_calls/merged_bed_file'
  
#  - id: lambda_bam_file
#    type: File
#    source: "#find_lambda_file/lambda_bam"

#  - id: methylation_calls_lambda
#    type: string
#    source: "#methylation_calling_lambda/methcall_bed"
  - id: bisulfite_conversion_estimation
    type: File
    outputSource: '#conversion_estimation_lambda/bisulfite_conversion_file'
steps:
- id: split_read1_files
  run: tools/split-compressed-files.cwl
  scatter: '#split_read1_files/file'
  in:
  - {id: file, source: '#inp_read1'}
  - id: size
    source: '#fastq_batch_size'
  - id: suffix
    source: '#inp_read1'
    valueFrom: _$(inputs.file.basename.substr(0,inputs.file.basename.lastIndexOf('.fastq')))_$(inputs.size/1000)k_R1.fastq
  - {id: max_reads, source: '#max_reads'}
  out:
  - {id: output}
- id: split_read2_files
  run: tools/split-compressed-files.cwl
  scatter: '#split_read2_files/file'
  in:
  - {id: file, source: '#inp_read2'}
  - id: size
    source: '#fastq_batch_size'
  - id: suffix
    source: '#inp_read2'
    valueFrom: _$(inputs.file.basename.substr(0,inputs.file.basename.lastIndexOf('.fastq')))_$(inputs.size/1000)k_R1.fastq
  - {id: max_reads, source: '#max_reads'}
  out:
  - {id: output}
- id: flatten1
  run: tools/flatten_fastq_arrays.cwl
  in:
  - {id: fastq_arrays, source: '#split_read1_files/output'}
  out:
  - {id: flattened_fastq_array}
- id: flatten2
  run: tools/flatten_fastq_arrays.cwl
  in:
  - {id: fastq_arrays, source: '#split_read2_files/output'}
  out:
  - {id: flattened_fastq_array}
- id: adaptor_trimming
  run: tools/trimmomatic.cwl
  scatter: ['#adaptor_trimming/input_read1_fastq_file', '#adaptor_trimming/input_read2_fastq_file']
  scatterMethod: dotproduct
  in:
  - {id: input_read1_fastq_file, source: '#flatten1/flattened_fastq_array'}
  - {id: input_read2_fastq_file, source: '#flatten2/flattened_fastq_array'}
  - {id: java_opts, default: '-XX:-UseCompressedClassPointers -Xmx3000M -verbose'}
  - {id: trimmomatic_jar_path, source: '#trimmomatic_jar_file'}
  - {id: end_mode, default: PE}
  - {id: input_adapters_file, source: '#trimmomatic_adapters_file'}
  - {id: phred, source: '#trimmomatic_phred'}
  - {id: illuminaclip, source: '#illuminaclip'}
  - {id: leading, source: '#trimmomatic_leading'}
  - {id: trailing, source: '#trimmomatic_trailing'}
  - {id: crop, source: '#trimmomatic_crop'}
  - {id: headcrop, source: '#trimmomatic_headcrop'}
  - {id: tailcrop, source: '#trimmomatic_tailcrop'}
  - {id: minlen, source: '#trimmomatic_minlen'}
  - {id: avgqual, source: '#trimmomatic_avgqual'}
  - {id: nthreads, default: 10}
  - id: log_filename
    source: '#flatten1/flattened_fastq_array'
    valueFrom: $(inputs.input_read1_fastq_file.basename.substr(0, inputs.input_read1_fastq_file.basename.lastIndexOf('.')))_trimming.log
  out:
  - {id: output_read1_trimmed_file}
  - {id: output_read2_trimmed_paired_file}
  - {id: output_log_file}
- id: alignment
  run: tools/bwameth.cwl
  scatter: ['#alignment/read1', '#alignment/read2']
  scatterMethod: dotproduct
  in:
     # - { id: threads, default: '1'}
    - {id: reference, source: '#reference_fasta'}
    - {id: read1, source: '#adaptor_trimming/output_read1_trimmed_file'}
    - {id: read2, source: '#adaptor_trimming/output_read2_trimmed_paired_file'}
    - id: alignment_filename
      source: '#adaptor_trimming/output_read1_trimmed_file'
      valueFrom: $(inputs.read1.basename.substr(0, inputs.read1.basename.lastIndexOf('.')))
    - {id: threads, default: 4}
    - {id: lib_type, source: '#lib_type'}
  out:
  - {id: alignment}
- id: flag_stat_aligned
  run: tools/samtools-flagstat.cwl
  scatter: '#flag_stat_aligned/input_bam_file'
  in:
  - {id: input_bam_file, source: '#alignment/alignment'}
  out:
  - {id: output}
- id: sam_to_bam
  run: tools/samtools-view.cwl
  scatter: '#sam_to_bam/input'
  in:
  - {id: input, source: '#alignment/alignment'}
  - {id: isbam, default: 'true'}
  - id: output_name
    source: '#alignment/alignment'
    valueFrom: $(inputs.input.basename.substr(0, inputs.input.basename.lastIndexOf('.'))).bam
  out:
  - {id: output}
- id: split_by_chromosome
  run: tools/bamtools-split.cwl
  scatter: '#split_by_chromosome/input_bam_file'
  in:
  - {id: file_dir, source: '#temp_dir'}
  - {id: input_bam_file, source: '#sam_to_bam/output'}
  - {id: split_options, default: reference}
  - {id: ref_prefix, source: '#chr_prefix'}
  out:
  - {id: output_bam_files}
- id: fix_all_bams
  run: tools/fix-all-bam-files.cwl
  scatter: '#fix_all_bams/array_of_bams'
  in:
  - {id: file_dir, source: '#temp_dir'}
  - id: array_of_bams
    source: '#split_by_chromosome/output_bam_files'
#        valueFrom: $([self])
  out:
  - {id: array_of_fixed_bams}
- id: rearrange_bams
  run: tools/rearrange_bams.cwl
  in:
  - id: bam_arrays
    source: '#fix_all_bams/array_of_fixed_bams'
  - id: chromosomes
    source: '#chromosomes'
  out:
  - {id: bam_arrays_per_chr}
  - {id: chrom_names}
- id: bam_merging
  run: tools/picard-MergeSamFiles.cwl
  scatter: ['#bam_merging/inputFileName_mergedSam', '#bam_merging/outputFileName_mergedSam']
  scatterMethod: dotproduct
  in:
  - id: inputFileName_mergedSam
    source: '#rearrange_bams/bam_arrays_per_chr'
  - id: outputFileName_mergedSam
    source: '#rearrange_bams/chrom_names'
    valueFrom: $(self)_merged.bam
  - {id: createIndex, default: 'true'}
  out:
  - {id: mergeSam_output}
- id: index_bam_file
  run: tools/samtools-index.cwl
  scatter: '#index_bam_file/input'
  in:
  - {id: input, source: '#bam_merging/mergeSam_output'}
  - {id: bai, default: true}
  out:
  - {id: index}
#### OLD MERGING                  
#  - id: bam_merging
#    run: "tools/picard-MergeSamFiles.cwl"
#    in:
#      - id: inputFileName_mergedSam 
#        source: "#alignment/alignment"
#      - { id: outputFileName_mergedSam, default: "merged_alignment.bam"}
#     # - { id: tmpdir, valueFrom: $(runtime.tmpdir)} # does not work due to some reason
#      - { id: tmpdir, default: "/ngs_share/tmp/"}
#      - { id: createIndex, default: "true" }
#    out:
#      - { id: mergeSam_output }
#                  
#  - id: duplicates_removal
#    run: "tools/picard-MarkDuplicates.cwl"
#    in:
#      - id: inputFileName_markDups
#        source: "#bam_merging/mergeSam_output"
#        valueFrom: $([self])
#      - { id: outputFileName_markDups, valueFrom: "merged_alignment.bam" }
#      #- { id: tmpdir, valueFrom: $(runtime.tmpdir) }
#      - { id: tmpdir, valueFrom: "/ngs_share/tmp/"}
#      - { id: removeDuplicates, valueFrom: "true" }
#      - { id: createIndex, valueFrom: "true" }
#      - { id: metricsFile, valueFrom: "duplicate_metrics.txt"}
#    out:
#      - { id: markDups_output }

- id: duplicates_removal
  run: tools/picard-MarkDuplicates.cwl
  scatter: '#duplicates_removal/inputFileName_markDups'
  in:
#      - { id: file_dir, source: "#temp_dir" }
    - id: inputFileName_markDups
        #source: "#split_by_chromosome/output_bam_files"
        #source: "#fix_bams/fixBam_output"
      source: '#bam_merging/mergeSam_output'
      valueFrom: $([self])
    - id: outputFileName_markDups
        #source: "#split_by_chromosome/output_bam_files"
      source: '#bam_merging/mergeSam_output'
      valueFrom: $(inputs.inputFileName_markDups.basename.substr(0, inputs.inputFileName_markDups.basename.lastIndexOf('.')))_dupl_removed.bam
    - {id: removeDuplicates, default: 'true'}
    - id: metricsFile
      source: '#bam_merging/mergeSam_output'
      valueFrom: $(inputs.inputFileName_markDups.basename.substr(0, inputs.inputFileName_markDups.basename.lastIndexOf('.')))_duplicate_metrics.txt
    - {id: createIndex, default: 'true'}
  out:
  - {id: markDups_output}
- id: flag_stat_dup_removed
  run: tools/samtools-flagstat.cwl
  scatter: '#flag_stat_dup_removed/input_bam_file'
  in:
  - {id: input_bam_file, source: '#duplicates_removal/markDups_output'}
  out:
  - {id: output}
- id: insert_size_dist
  run: tools/picard-InsertSizeMetric.cwl
  scatter: '#insert_size_dist/inputFileName_insertSize'
  in:
  - id: inputFileName_insertSize
#        source: "#fix_bams/fixBam_output"
    source: '#duplicates_removal/markDups_output'
  - id: outputFileName_insertSize
    source: '#duplicates_removal/markDups_output'
    valueFrom: $( inputs.inputFileName_insertSize.basename.substr(0, inputs.inputFileName_insertSize.basename.lastIndexOf('.'))
      + '_insert_size_metrix.txt')
  - id: histogramFile
    source: '#duplicates_removal/markDups_output'
    valueFrom: $( inputs.inputFileName_insertSize.basename.substr(0, inputs.inputFileName_insertSize.basename.lastIndexOf('.'))
      + '_insert_size_histogram.pdf')
  - {id: createIndex, default: 'true'}
  out:
  - {id: insertSize_output}
- id: mbias_calculation
  run: tools/pileometh-mbias.cwl
  scatter: '#mbias_calculation/bam_file'
  in:
  - {id: bam_file, source: '#duplicates_removal/markDups_output'}      #"#bam_merging/mergeSam_output"
  
#      - { id: bam_file, source: "#bam_merging/mergeSam_output" }
  - id: reference
    source: '#reference_fasta'
  - id: mbiasfile_name
    source: '#duplicates_removal/markDups_output'
    valueFrom: $(inputs.bam_file.basename.substr(0, inputs.bam_file.basename.lastIndexOf('.')))_mbias
  out:
  - {id: mbias_file}
- id: mbias_calculation_trimmed
  run: tools/methyldackel-mbias.cwl
  scatter: '#mbias_calculation_trimmed/bam_file'
  in:
  - {id: bam_file, source: '#duplicates_removal/markDups_output'}      #"#bam_merging/mergeSam_output"
  
#      - { id: bam_file, source: "#bam_merging/mergeSam_output" }
  - id: reference
    source: '#reference_fasta'
  - id: mbiasfile_name
    source: '#duplicates_removal/markDups_output'
    valueFrom: $(inputs.bam_file.basename.substr(inputs.bam_file.basename.lastIndexOf('/')+1,
      inputs.bam_file.basename.lastIndexOf('.')))_mbiasTrimmed
  - {id: OT, source: '#pileometh_ot'}
  - {id: OB, source: '#pileometh_ob'}
  - {id: CTOT, source: '#pileometh_ctot'}
  - {id: CTOB, source: '#pileometh_ctob'}
  - {id: nOT, source: '#pileometh_not'}
  - {id: nOB, source: '#pileometh_nob'}
  - {id: nCTOT, source: '#pileometh_nctot'}
  - {id: nCTOB, source: '#pileometh_nctob'}
  - {id: min_phred, source: '#pileometh_min_phred'}
  - {id: min_depth, source: '#pileometh_min_depth'}
  - {id: min_mapq, source: '#pileometh_min_mapq'}
  out:
  - {id: mbias_file}
- id: methylation_calling
  run: tools/methyldackel-extract.cwl
  scatter: '#methylation_calling/bam_file'
  in:
  - id: bam_file
        #source: "#split_by_chromosome/output_bam_files"
    source: '#duplicates_removal/markDups_output'
  - id: bedfile_name
        #source: "#split_by_chromosome/output_bam_files"
    source: '#duplicates_removal/markDups_output'
    valueFrom: $(inputs.bam_file.basename.substr(0, inputs.bam_file.basename.lastIndexOf('.')))
  - id: reference
    source: '#reference_fasta'
  - {id: noCG, default: false}
  - {id: OT, source: '#pileometh_ot'}
  - {id: OB, source: '#pileometh_ob'}
  - {id: CTOT, source: '#pileometh_ctot'}
  - {id: CTOB, source: '#pileometh_ctob'}
  - {id: nOT, source: '#pileometh_not'}
  - {id: nOB, source: '#pileometh_nob'}
  - {id: nCTOT, source: '#pileometh_nctot'}
  - {id: nCTOB, source: '#pileometh_nctob'}
  - {id: min_phred, source: '#pileometh_min_phred'}
  - {id: min_depth, source: '#pileometh_min_depth'}
  - {id: min_mapq, source: '#pileometh_min_mapq'}
  out:
  - {id: methcall_bed}
- id: merge_meth_calls
  run: tools/methcall-merger.cwl
  in:
  - id: input_bed_files
    source: '#methylation_calling/methcall_bed'
  - id: output_file_name
    valueFrom: methylation_calls_CpG.bedGraph
  out:
  - {id: merged_bed_file}
- id: find_lambda_file
  run: tools/find_lambda.cwl
  in:
  - {id: split_files, source: '#duplicates_removal/markDups_output'}
  out:
  - {id: lambda_bam}
- id: methylation_calling_lambda
  run: tools/methyldackel-extract.cwl
  in:
  - id: reference
    source: '#reference_fasta'
  - {id: noCG, default: true}
  - {id: bedfile_name, default: lambda}
  - {id: OT, source: '#pileometh_ot'}
  - {id: OB, source: '#pileometh_ob'}
  - {id: CTOT, source: '#pileometh_ctot'}
  - {id: CTOB, source: '#pileometh_ctob'}
  - {id: nOT, source: '#pileometh_not'}
  - {id: nOB, source: '#pileometh_nob'}
  - {id: nCTOT, source: '#pileometh_nctot'}
  - {id: nCTOB, source: '#pileometh_nctob'}
  - id: bam_file
    source: '#find_lambda_file/lambda_bam'
#      - id: bam_file
#        source: "#test_bam"
#        valueFrom: $([self])
#      - { id: bam_file, source: "#duplicates_removal/markDups_output" }
  out:
  - {id: methcall_bed}
- id: conversion_estimation_lambda
  run: tools/bisulfite-conversion-lambda.cwl
  in:
  - id: input_bed_file
    source: '#methylation_calling_lambda/methcall_bed'
  - id: output_file_name
    valueFrom: bisulfite_conversion.txt
  out:
  - {id: bisulfite_conversion_file}

