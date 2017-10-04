#!/usr/bin/env bash


##add a better option here: it should check if it has everything

for ((i=1;i<=$#;i++)); 
do
    if [ ${!i} = "--paired" ] 
    then
        paired=true;
    elif [ ${!i} = "--lanes" ];
		then  ((i++)) 
		lanes=${!i};    
    elif [ ${!i} = "--input_loc" ];
		then  ((i++)) 
		input_loc=${!i};  
    elif [ ${!i} = "--read1" ];
		then  ((i++)) 
		read1=${!i};  
    elif [ ${!i} = "--read2" ];
		then  ((i++)) 
		read2=${!i};  
    elif [ ${!i} = "--library" ];
		then  ((i++)) 
		library=${!i};  
    elif [ ${!i} = "--tmp" ];
		then  ((i++)) 
		tmp=${!i};  
    elif [ ${!i} = "--logs" ];
		then  ((i++)) 
		logs=${!i}; 
    elif [ ${!i} = "--reports" ];
		then  ((i++)) 
		reports=${!i}; 
    elif [ ${!i} = "--reference_loc" ];
		then  ((i++)) 
		reference_loc=${!i};  
    elif [ ${!i} = "--output_loc" ];
		then  ((i++)) 
		output_loc=${!i};  
    elif [ ${!i} = "--bowtie_threads" ];
		then  ((i++)) 
		bowtie_threads=${!i};  
    fi
done


echo "This is the log for processing of the library $library" >> ${logs}/$library.log
echo "The input variables were the following:" >> ${logs}/$library.log
echo "Paired: $paired" >> ${logs}/$library.log
echo "Number of lanes: $lanes" >> ${logs}/$library.log
echo "Input files, read 1: $input_loc/$read1.fq.gz" >> ${logs}/$library.log
if $paired; then
echo "Input files, read 2: $input_loc/$read2.fq.gz" >> ${logs}/$library.log
fi
echo "The name of the library: $library " >> ${logs}/$library.log
echo "Folder for temporary files: $tmp " >> ${logs}/$library.log
echo "Folder for logs: $logs " >> ${logs}/$library.log
echo "Location of the reference file: $reference_loc " >> ${logs}/$library.log


now=$(date +%H:%M:%S)
now_day=$(date +%d.%m.%y)
echo "The analysis was started on $now_day at $now" >> ${logs}/$library.log


if [ ! -d ${logs} ]
then 
echo "ERROR: ${logs} directory is not existing." >> ${logs}/$library.log
exit 1 
fi

if [ ! -d ${tmp} ]
then 
echo "ERROR: ${tmp} directory is not existing." >> ${logs}/$library.log
exit 1 
fi

if [ ! -d ${reports} ]
then 
echo "ERROR: ${reports} directory is not existing." >> ${logs}/$library.log
exit 1 
fi

if [ ${lanes} -ne 1 ]
then 
echo "ERROR: Currently only works with one lane." >> ${logs}/$library.log
exit 1 
fi

if [ ! -d ${reference_loc} ]
then 
echo "ERROR: ${reference_loc}/Bisulfite_Genome directory is not existing." >> ${logs}/$library.log
exit 1 
fi

####################tools######################################
. ./tools.sh
####################paired#####################################
################################################################
if $paired; then

#check input files

	if [ ! -e "${input_loc}/${read1}.fastq.gz" ]
	then 
		echo "ERROR: ${input_loc}/${read1}.fastq.gz is not existing." >> ${logs}/$library.log
		exit 1 
	fi
	if [ ! -e "${input_loc}/${read2}.fastq.gz" ]
		then 
		echo "ERROR: ${input_loc}/${read2}.fastq.gz is not existing." >> ${logs}/$library.log
	exit 1
	fi

#start processing

	${trim_galore_loc}/trim_galore ${input_loc}/${read1}.fastq.gz ${input_loc}/${read2}.fastq.gz --paired  --fastqc -o ${tmp} --fastqc_args "--outdir ${tmp}" 

	if [ "$?" -ne 0 ]; then
		echo "ERROR: trim galore stopped with error." >> ${logs}/$library.log
		exit 1
	fi

########## copy (later move) all the report files into a report folder. Later, apply multiqc on it. 

	cp ${tmp}/${read1}_val_1.fq_fastqc ${reports}/${read1}_val_1.fq_fastqc 
	cp ${tmp}/${read2}_val_2.fq_fastqc ${reports}/${read2}_val_2.fq_fastqc 

	cp ${tmp}/${read1}.fastq.gz_trimming_report.txt ${reports}/${read1}.fastq.gz_trimming_report.txt
	cp ${tmp}/${read2}.fastq.gz_trimming_report.txt ${reports}/${read2}.fastq.gz_trimming_report.txt

	now=$(date +%H:%M:%S)
	now_day=$(date +%d.%m.%y)
	echo "Trim Galore finished on $now_day at $now" >> ${logs}/$library.log

###########alignment#########################################################

	${bismark_loc}/bismark --multicore ${bowtie_threads} --bowtie1 --path_to_bowtie ${bowtie_loc} --samtools_path ${samtools_loc} --output_dir ${output_loc} --temp_dir ${tmp}  \
	--gzip  ${reference_loc} -1 ${tmp}/${read1}_val_1.fq.gz -2  ${tmp}/${read2}_val_2.fq.gz

	#cp ${output_loc}/${read1}_val_1.fq.gz_bismark_PE_report.txt ${reports}/${read1}_val_1.fq.gz_bismark_PE_report.txt
	#cp ${output_loc}/${read1}_val_1.fq.gz_bismark_PE_report.txt ${reports}/${read1}_val_1.fq.gz_bismark_PE_report.txt  	

	if [ "$?" -ne 0 ]; then
	echo "ERROR: bismark stopped with error." >> ${logs}/$library.log
	exit 1
	fi

	mv ${output_loc}/${read1}_val_1_bismark_pe.bam ${output_loc}/${library}_pe.bam

	now=$(date +%H:%M:%S)
	now_day=$(date +%d.%m.%y)
	echo "Bismark finished on $now_day at $now" >> ${logs}/$library.log

########further optimizable: the duplicate removal of picard >2 is able to work on data sorted by queryname. with this, one sorting process can be saved. (12 h)

#####################coordinate sorting#######################################


	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/SortSam.jar I=${output_loc}/${library}_pe.bam  \
	O=${tmp}/${library}_pe_sorted.bam SORT_ORDER=coordinate TMP_DIR=${tmp}

	if [ "$?" -ne 0 ]; then
		echo "ERROR: SortSam stopped with error." >> ${logs}/$library.log
		exit 1
	fi
	now=$(date +%H:%M:%S)
	echo "SortSam finished at $now" >> ${logs}/$library.log

#####################mark duplicates############################################

	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/MarkDuplicates.jar I=${tmp}/${library}_pe_sorted.bam  \
	O=${tmp}/${library}_pe_sorted_mkdup.bam REMOVE_DUPLICATES=true \
	AS=true TMP_DIR=${tmp} \
	METRICS_FILE=${reports}/${library}.mkdup.metrics VALIDATION_STRINGENCY=SILENT 

	if [ "$?" -ne 0 ]; then
		echo "ERROR: MarkDuplicates stopped with error." >> ${logs}/$library.log
		exit 1
	fi

	now=$(date +%H:%M:%S)
	echo "MarkDuplicates finished at $now" >> ${logs}/$library.log

#####################queryname sorting#######################################

	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/SortSam.jar I=${tmp}/${library}_pe_sorted_mkdup.bam  \
	O=${output_loc}/${library}_pe_unsorted_mkdup.bam SORT_ORDER=queryname TMP_DIR=${tmp}

	if [ "$?" -ne 0 ]; then
		echo "ERROR: SortSam stopped with error." >> ${logs}/$library.log
		exit 1
		fi
	now=$(date +%H:%M:%S)
	echo "SortSam finished at $now" >> ${logs}/$library.log


####################M-bias plotting ################################################

	${bismark_loc}/bismark_methylation_extractor --multicore $bowtie_threads -p --no_overlap --mbias_only -o ${output_loc} \
	-samtools_path ${samtools_loc} ${output_loc}/${library}_pe_unsorted_mkdup.bam  2> ${reports}/${library}.bcall_Mplot.log 
	 
	cp ${output_loc}/${library}_pe_unsorted_mkdup.M-bias.txt ${reports}/${library}_pe_unsorted_mkdup.M-bias.txt
	cp ${output_loc}/${library}_pe_unsorted_mkdup_splitting_report.txt ${reports}/${library}_pe_unsorted_mkdup_splitting_report.txt


#############################not paired#####################################
############################################################################

elif !($paired); then

#check imput file
	if [ ! -e "${input_loc}/${read1}.fastq.gz" ]
		then 
		print "ERROR: ${input_loc}/${read1}.fastq.gz is not existing." >> ${logs}/$library.log
		exit 1 
	fi

#start processing
	${trim_galore_loc}/trim_galore ${input_loc}/${read1}.fastq.gz -o ${tmp} --fastqc  --fastqc_args "--outdir ${tmp}"
	if [ "$?" -ne 0 ]; then
		echo "ERROR: trim galore stopped with error." >> ${logs}/$library.log
		exit 1
	fi

	now=$(date +%H:%M:%S)
	now_day=$(date +%d.%m.%y)
	echo "Trim Galore finished on $now_day at $now" >> ${logs}/$library.log

###########alignment#########################################################

	${bismark_loc}/bismark --multicore $bowtie_threads --bowtie1 --se --path_to_bowtie ${bowtie_loc} --samtools_path ${samtools_loc} --output_dir ${output_loc} \
 	--temp_dir ${tmp}  --gzip  ${reference_loc} ${tmp}/${read1}.fq.gz
 

	if [ "$?" -ne 0 ]; then
		echo "ERROR: Bismark stopped with error." >> ${logs}/$library.log
		exit 1
	fi

	now=$(date +%H:%M:%S)
	now_day=$(date +%d.%m.%y)
	echo "Bismark finished on $now_day at $now" >> ${logs}/$library.log

	#check this!!!!!!!
	mv ${output_loc}/${read1}_val_1.fq.gz_bismark_se.bam ${output_loc}/${library}_se.bam


#####################coordinate sorting#######################################

	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/SortSam.jar I=${output_loc}/${library}_se.bam  \
	O=${tmp}/${library}_se_sorted.bam SORT_ORDER=coordinate

	if [ "$?" -ne 0 ]; then
		echo "ERROR: SortSam stopped with error." >> ${logs}/$library.log
		exit 1
	fi
	now=$(date +%H:%M:%S)
	echo "SortSam finished at $now" >> ${logs}/$library.log

#####################mark duplicates############################################

	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/MarkDuplicates.jar I=${tmp}/${library}_se_sorted.bam  \
	O=${tmp}/${library}_se_sorted_mkdup.bam REMOVE_DUPLICATES=true \
	AS=true \
	METRICS_FILE=${logs}/${library}.mkdup.metrics VALIDATION_STRINGENCY=SILENT 


	if [ "$?" -ne 0 ]; then
		echo "ERROR: MarkDuplicates stopped with error." >> ${logs}/$library.log
		exit 1
	fi

	now=$(date +%H:%M:%S)
	echo "MarkDuplicates finished at $now" >> ${logs}/$library.log

#####################queryname sorting#######################################

	java -Xmx20g -XX:ParallelGCThreads=3 -XX:ParallelCMSThreads=3 -Dsamjdk.use_async_io=false \
	-jar ${picard_loc}/SortSam.jar I=${tmp}/${library}_se_sorted_mkdup.bam  \
	O=${output}/${library}_se_unsorted_mkdup.bam SORT_ORDER=queryname

	if [ "$?" -ne 0 ]; then
		echo "ERROR: SortSam stopped with error." >> ${logs}/$library.log
		exit 1
	fi
	now=$(date +%H:%M:%S)
	echo "SortSam finished at $now" >> ${logs}/$library.log


####################M-bias plotting ################################################

	${bismark_loc}/bismark_methylation_extractor --multicore $bowtie_threads -s --mbias_only -o ${output_loc} \
	-samtools_path ${samtools_loc} ${output}/${library}_se_unsorted_mkdup.bam   2> ${logs}/${library}.bcall_Mplot.log 

fi

#####################common##########################


now=$(date +%H:%M:%S)
echo "Calculation of M-bias plot finished at $now" >> ${logs}/$library.log
echo "If you want to call the methylation levels, fill in the new sample sheet and run pipeline_meth_ext.py" >> ${logs}/$library.log


