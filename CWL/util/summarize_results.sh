#!/bin/sh

#
# Summarize results of a WGBS pipeline
#

SRC_DIR=$(dirname "$0")
ANALYSIS_DIR=$1
FILE_DIR=$2

REPORT_FILE=$ANALYSIS_DIR/"summary.txt"

CUR_DIR=`pwd`
cd $FILE_DIR

sh $SRC_DIR/summarize_trimmomatic.sh 

echo "" >> $REPORT_FILE
echo "==== Trimming ==== " >> $REPORT_FILE
echo "" >> $REPORT_FILE
cat "trimming_summary.txt" >> $REPORT_FILE


sh $SRC_DIR/summarize_flagstat.sh "trimmed" 

echo "" >> $REPORT_FILE
echo "==== Flagstat aligned ==== " >> $REPORT_FILE
echo "" >> $REPORT_FILE
cat "flagstat_trimmed_summary.txt" >> $REPORT_FILE


sh $SRC_DIR/summarize_flagstat.sh "dupl_removed" 

echo "" >> $REPORT_FILE
echo "==== Flagstat duplicate removed ==== " >> $REPORT_FILE
echo "" >> $REPORT_FILE
cat "flagstat_dupl_removed_summary.txt" >> $REPORT_FILE

sh $SRC_DIR/summarize_coverage.sh ${ANALYSIS_DIR}/out/methylation_calls_CpG.bedGraph

	
echo "" >> $REPORT_FILE
echo "==== Bisulfite conversion ==== " >> $REPORT_FILE
echo "" >> $REPORT_FILE
conv_ctrl_chr=`ls -1 $FILE_DIR | grep CHH | sed 's/_CHH.bedGraph//g'` 
echo "Estimated using: "$conv_ctrl_chr >> $REPORT_FILE
conv_rate=`cat ${ANALYSIS_DIR}/out/bisulfite_conversion.txt`
echo "Conversion rate: "$conv_rate >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "==== Coverage ==== " >> $REPORT_FILE
echo "" >> $REPORT_FILE
cat "coverage_summary.txt" >> $REPORT_FILE

cd $CUR_DIR