#!/bin/bash
#
#	A watchdog script for running the assigned WGBS samples
#

PATH=/opt/sge/bin:/opt/sge/bin/lx-amd64:/opt/miniconda/bin/:$PATH
export PATH

. /etc/profile.d/sge.sh

WATCH_DIR=/ngs_share/pipeline_jobs/BSseq/input/
PROGRESS_DIR=/ngs_share/pipeline_jobs/BSseq/progress/
COMPLETED_DIR=/ngs_share/pipeline_jobs/BSseq/completed/
PID_DIR=/ngs_share/pipeline_jobs/BSseq/pids/
CWL_PIPELINE_DIR=/ngs_share/pipelines/BSseq/CWL/
MONITORING_DIR=/ngs_share/pipeline_reporting/BSseq/
MAX_RUNNING_JOBS=1


JOB_FILES=`ls -1 $WATCH_DIR | grep -e ".json$\|.yml$"`

#if [ ! -e /proc/$pid -a /proc/$pid/exe ]

IN_PROGRESS=`ls -1 $PROGRESS_DIR | grep -e ".json$\|.yml$" | wc -l`
TO_DO=`ls -1 $WATCH_DIR | grep -e ".json$\|.yml$" | wc -l`

if [[ $IN_PROGRESS -lt $MAX_RUNNING_JOBS && $TO_DO -gt 0 ]]
then
		job_file=`ls -t $WATCH_DIR | grep -e ".json$\|.yml$" | tail -n 1`
		analysis_dir=`cat $WATCH_DIR/$job_file | grep analysis_dir | sed -e 's/\"*analysis_dir\"*:\s*//g' | sed -e 's/,$//g' | sed -e 's/\"//g' `
		file_dir=`cat $WATCH_DIR/$job_file | grep temp_dir | sed -e 's/\"*temp_dir\"*:\s*//g' | sed -e 's/,$//g' | sed -e 's/\"//g' `
		mkdir -p $file_dir
		#analysis_dir=`date| sed 's/\s/_/g' | sed 's/:/_/g'`
		mkdir -p $analysis_dir/out
		mkdir -p $analysis_dir/work
		mkdir -p $analysis_dir/base
		
		mv ${WATCH_DIR}/$job_file $PROGRESS_DIR
		
		timestamp=`date --utc +%Y%m%d_%H%M%SZ`
		work_dir=$PID_DIR/${timestamp}_${job_file%.*}
		mkdir $work_dir
		cd $work_dir
		
		if grep -q "input_bam_files" $PROGRESS_DIR/$job_file
		then
			CWL_PIPELINE_FILE=wgbs-workflow-production-bams.yaml
		else
			CWL_PIPELINE_FILE=wgbs-workflow-production.yaml
		fi
		
		#source activate toil_bwameth_upd
		source activate toil_nondir
		cwltoil --logDebug --maxCores 10 --disableCaching --jobStore=${analysis_dir}/jobstore --workDir=${analysis_dir}/work --basedir=${analysis_dir}/base --outdir=${analysis_dir}/out --batchSystem=gridEngine ${CWL_PIPELINE_DIR}/$CWL_PIPELINE_FILE $PROGRESS_DIR/$job_file > ${analysis_dir}/toil.log 2>&1
		source deactivate
		
		sh ${CWL_PIPELINE_DIR}/util/summarize_results.sh $analysis_dir $file_dir
		
		mv $PROGRESS_DIR/$timestamp_$job_file $COMPLETED_DIR/${timestamp}_${job_file}
else
		running_job=`ls -t $PID_DIR | head -n 1`
		mkdir ${MONITORING_DIR}/${running_job}
		sh ${CWL_PIPELINE_DIR}/util/resource_monitoring.sh ${MONITORING_DIR}/${running_job}
fi



