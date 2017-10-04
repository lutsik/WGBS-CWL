#
# Script that loads the GPCF meta file and prepares the CWL job files
#
#
require(rjson)
prepare_wgbs_run<-function(
		settings=NULL,
		meta_file,
		data_dir,
		work_dir,
		output_dir,
		start_from_bams=FALSE,
		multisample=FALSE){
	
	run_input<-list()
	
	work_dir<-normalizePath(work_dir)
	
#	if(!start_from_bams){
	meta_info<-read.table(meta_file, sep="\t", header=TRUE, stringsAsFactors=FALSE)
#	}else{
#		sample_dirs<-list.dirs(data_dir)
#		meta_info<-data.frame(SAMPLE_ID_CLEAN=sample_dirs)
#		bam_files<-lapply(file.path(sample_dirs, "files"), list.files, pattern="*.bam")
#		names(bam_files)<-meta_info$SAMPLE_ID_CLEAN
#	}
	
	meta_info$SAMPLE_ID_CLEAN<-gsub("[[:punct:]]", "_", meta_info$SAMPLE_ID)
	meta_info$SAMPLE_ID_CLEAN<-gsub(" ", "_", meta_info$SAMPLE_ID_CLEAN)
	
	samples<-unique(meta_info$SAMPLE_ID_CLEAN)
	
	DEFAULT<-list(
		reference_fasta= "/ngs_share/data/genomes/Hsapiens/GRCh37/bwameth/GRCh37.lambda.fa",
		chromosomes= c(
				'chr1', 
				'chr2', 
				'chr3', 
				'chr4', 
				'chr5', 
				'chr6', 
				'chr7', 
				'chr8', 
				'chr9', 
				'chr10', 
				'chr11',
				'chr12', 
				'chr13', 
				'chr14', 
				'chr15', 
				'chr16', 
				'chr17', 
				'chr18', 
				'chr19', 
				'chr20', 
				'chr21',
				'chr22', 
				'chrX', 
				'chrY', 
				'chrMT',
				'chrLambda'),
		chr_prefix= "chr",
		fastq_batch_size= 40000000,
		max_reads= 100000,
		lib_type = "directional",
		trimmomatic_jar_file= '/opt/miniconda/pkgs/trimmomatic-0.36-3/share/trimmomatic/trimmomatic.jar',
		trimmomatic_adapters_file= '/opt/miniconda/pkgs/trimmomatic-0.36-3/share/trimmomatic/adapters/TruSeq2-PE.fa',
		trimmomatic_phred= "33",
		illuminaclip= "2:30:10:8:true",
		trimmomatic_leading= 0 ,
		trimmomatic_trailing= 0,
		trimmomatic_crop= 1000,
		trimmomatic_headcrop= 0,
		trimmomatic_tailcrop= 0,
		trimmomatic_minlen= 0,
		trimmomatic_avgqual= 1,
		pileometh_min_mapq= 0,
		pileometh_min_phred= 0,
		pileometh_min_depth= 1,
		pileometh_ot= "0,0,0,0",
		pileometh_ob= "0,0,0,0",
		pileometh_ctot= "0,0,0,0",
		pileometh_ctob= "0,0,0,0",
		pileometh_not= "0,0,0,0",
		pileometh_nob= "0,0,0,0",
		pileometh_nctot= "0,0,0,0",
		pileometh_nctob= "0,0,0,0",
		temp_dir= "/ngs_share/tmp/wgbs_cwl_test/files",
		analysis_dir="/ngs_share/tmp/wgbs_cwl_test/",
		clean_raw_fastqs= "false",
		clean_trimmed_fastqs= "false",
		clean_primary_sams= "false",
		clean_primary_bams= "false",
		clean_chr_bams= "false",
		clean_merged_bams= "false",
		clean_dup_rm_bams= "false"	
	)
	
	if(is.null(settings)){
		settings<-DEFAULT
	}
	if(!multisample){
		for(sample in samples) {
			run_input[[sample]]<-list()
		}
	}
	for(opt in names(DEFAULT)){
		if(multisample){
			if(!is.null(settings[[opt]])){
				run_input[[opt]]<-settings[[opt]]
			}else{
				run_input[[opt]]<-DEFAULT[[opt]]
			}
		}else{
			for(sample in samples){
				if(!is.null(settings[[opt]])){
 					run_input[[sample]][[opt]]<-settings[[opt]]
				}else{
					run_input[[sample]][[opt]]<-DEFAULT[[opt]]
				}
			}
		}
	}
	
	search_files<-function(filename, root_dir){
		fastq.files <- list.files(root_dir, pattern = sprintf("%s$",gsub("\\.", "\\\\.", filename)), recursive = TRUE)
		file.path(root_dir, fastq.files)
	}
	
	meta_info$FULL_FASTQ_PATHS<-sapply(meta_info$FASTQ_FILE, search_files, data_dir)
	
	
	prepare_record<-function(sample_name, meta_info){
		
		output<-list()
		
		records<-meta_info[meta_info$SAMPLE_ID_CLEAN==sample_name,,drop=FALSE]
		records<-records[order(records$FASTQ_FILE),]
		
		mates<-c(1,2)
		
		for(mate in mates){
			mate_lines<-records[records$MATE==mate,,drop=FALSE]
			#names(mate_lines)<-NULL
			output[[mate]]<-as.list(mate_lines$FULL_FASTQ_PATHS)
		}
		
		output
	}

	if(multisample){
		
		run_input$fastq_files<-lapply(samples, prepare_record, meta_info)
		run_input$analysis_dir<-work_dir
		run_input$temp_dir<-file.path(run_input$analysis_dir, "files")
		dir.create(run_input$temp_dir)
		
	}else{
		for(sample in samples){
			
			run_input[[sample]][["analysis_dir"]]<-file.path(work_dir, sample)
			if(!start_from_bams) dir.create(run_input[[sample]][["analysis_dir"]])
			run_input[[sample]][["temp_dir"]]<-file.path(run_input[[sample]][["analysis_dir"]], "files")
			if(!start_from_bams) dir.create(run_input[[sample]][["temp_dir"]])
			
			if(!start_from_bams){
				input_files<-prepare_record(sample, meta_info)
				names(input_files[[1]])<-NULL
				names(input_files[[2]])<-NULL
				
				run_input[[sample]][["inp_read1"]]<-input_files[[1]]
				run_input[[sample]][["inp_read2"]]<-input_files[[2]]
			}else{
				input_bams<-list.files(run_input[[sample]][["temp_dir"]], pattern="*.bam")
				run_input[[sample]][["input_bam_files"]]<-as.list(input_bams)
			}
			
		}
	}

	if(multisample){

		output_file<-file.path(output_dir, "cwl-job.json")
		
		json_file<-toJSON(run_input)
		json_file<-gsub(",", ",\n", json_file)
		
		cat(json_file, file=output_file)
		
	}else{
		
		for(sample in names(run_input)){
			
			output_file<-file.path(output_dir, sprintf("%s_cwl-job.json", sample))
			
			json_file<-toJSON(run_input[[sample]])
			json_file<-gsub("],", "],\n", json_file)
			json_file<-gsub("\",", "\",\n", json_file)
			json_file<-gsub(",\"", ",\n\"", json_file)
			json_file<-gsub("\"false\"", "false", json_file)
			json_file<-gsub("\"true\"", "true", json_file)
			
			cat(json_file, file=output_file)
		}
	}
	
	output<-list()
	output[["cwl_input"]]<-run_input
	output[["bed_files"]]<-data.frame(SampleID=samples, BED=file.path(work_dir, samples, "out", "methylation_calls_CpG.bedGraph"))
	return(invisible(output))
}
