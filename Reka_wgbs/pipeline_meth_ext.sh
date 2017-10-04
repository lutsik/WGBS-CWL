#!/usr/bin/env bash


##add a better option here: it should check if it has everything
paired=false
bwa_cores=1
for ((i=1;i<=$#;i++)); 
do
    if [ ${!i} = "--paired" ] 
    		then 
		paired=true; 
    elif [ ${!i} = "--input_loc" ];
		then  ((i++)) 
		input_loc=${!i};  
    elif [ ${!i} = "--ignore" ];
		then  ((i++)) 
		ignore=${!i};  
    elif [ ${!i} = "--ignore_r2" ];
		then  ((i++)) 
		ignore_r2=${!i};  
    elif [ ${!i} = "--ignore_3prime" ];
		then  ((i++)) 
		ignore_3prime=${!i};  
    elif [ ${!i} = "--ignore_3prime_r2" ];
		then  ((i++)) 
		ignore_3prime_r2=${!i};  
    elif [ ${!i} = "--library" ];
		then  ((i++)) 
		library=${!i};  
    elif [ ${!i} = "--tmp" ];
		then  ((i++)) 
		tmp=${!i};  
    elif [ ${!i} = "--logs" ];
		then  ((i++)) 
		logs=${!i};  
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


echo "This is the log of methylation calling." >> ${logs}/$library.log
echo "The input variables were the following:" >> ${logs}/$library.log
echo "Paired: $paired" >> ${logs}/$library.log

if $paired; then
echo "Expected input file: ${output_loc}/${library}_pe.deduplicated.bam" >> ${logs}/$library.log
elif !($paired); then
echo "Expected input file: ${output_loc}/${library}_se.deduplicated.bam" >> ${logs}/$library.log
fi
echo "The name of the library: $library " >> ${logs}/$library.log
echo "Folder for temporary files: $tmp " >> ${logs}/$library.log
echo "Folder for logs: $logs " >> ${logs}/$library.log
echo "Location of the reference file: $reference_loc " >> ${logs}/$library.log


now=$(date +%H:%M:%S)
now_day=$(date +%d.%m.%y)
echo "The methylation calling was started on $now_day at $now" >> ${logs}/$library.log


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


if [ ! -d ${reference_loc}/Bisulfite_Genome ]
then 
echo "ERROR: ${reference_loc}/Bisulfite_Genome directory is not existing." >> ${logs}/$library.log
exit 1 
fi

####################tools######################################

. ./tools.sh

####################paired#####################################
if $paired; then

#check input files

	if [ ! -e "${output_loc}/${library}_pe_unsorted_mkdup.bam" ]
		then 
		echo "ERROR: ${output_loc}/${library}_pe_unsorted_mkdup.bam is not existing." >> ${logs}/$library.log
		exit 1 
	fi


#start processing

	${bismark_loc}/bismark_methylation_extractor -p --no_overlap -o ${output_loc} --bedGraph --comprehensive --multicore ${bowtie_threads} --cutoff 5 --gzip \
	--ignore ${ignore} --ignore_r2 ${ignore_r2} --ignore_3prime ${ignore_3prime} --ignore_3prime_r2 ${ignore_3prime_r2} \
	--samtools_path ${samtools_loc}/samtools ${output_loc}/${library}_pe_unsorted_mkdup.bam  2> ${logs}/${library}.bcall.log 
#${tabix_loc}/tabix -s 1 -b 2 -e 2 ${output_loc}/${library}.call.gz

	if [ "$?" -ne 0 ]; then
		echo "ERROR:bismark_methylation_extractor stopped with error." >> ${logs}/$library.log
		exit 1
	fi


	now=$(date +%H:%M:%S)
	now_day=$(date +%d.%m.%y)
	echo "The analysis finished on $now_day at $now" >> ${logs}/$library.log


elif !($paired); then

#check imput file
	if [ ! -e " ${output_loc}/${library}_se.deduplicated.bam" ]
		then 
		echo "ERROR:  ${output_loc}/${library}_se.deduplicated.bam is not existing." >> ${logs}/$library.log
		exit 1 
	fi

#start processing
${bismark_loc}/bismark_methylation_extractor --no_overlap -o ${output_loc} --bedGraph --comprehensive --multicore ${bowtie_threads} --cutoff 1 --gzip \
	--ignore ${ignore}  --ignore_3prime ${ignore_3prime}  \
	--samtools_path ${samtools_loc}/samtools ${output}/${library}_se_unsorted_mkdup.bam  2> ${logs}/${library}.bcall.log 
#${tabix_loc}/tabix -s 1 -b 2 -e 2 ${output_loc}/${library}.call.gz


fi


