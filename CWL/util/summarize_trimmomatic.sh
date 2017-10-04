#!/bin/sh
#
#

trim_logs=`ls -1 | grep trimming_stdout.log`
trim_reports=`ls -1 | grep trimming.log`

READ_PAIRS=0
BOTH_SURVIVING=0
FWD_SURVIVING=0
REV_SURVIVING=0
DROPPED=0

OUTPUT_FILE="trimming_summary.txt"

for tl in $trim_logs
do
	RESULT_LINE=`cat $tl | grep -e "^Input Read Pairs"` 
	BATCH_INPUT_READ_PAIRS=`echo $RESULT_LINE | sed "s/^Input Read Pairs:\s\([0-9]*\).*/\1/g"`
	BATCH_BOTH_SURVIVING=`echo $RESULT_LINE | sed "s/.*Both Surviving:\s\([0-9]*\).*/\1/g"`
	BATCH_FWD_SURVIVING=`echo $RESULT_LINE | sed "s/.*Forward Only Surviving:\s\([0-9]*\).*/\1/g"`
	BATCH_REV_SURVIVING=`echo $RESULT_LINE | sed "s/.*Reverse Only Surviving:\s\([0-9]*\).*/\1/g"`
	BATCH_DROPPED=`echo $RESULT_LINE | sed "s/.*Dropped:\s\([0-9]*\).*/\1/g"`
	
	
	READ_PAIRS=$((READ_PAIRS+BATCH_INPUT_READ_PAIRS))
	BOTH_SURVIVING=$((BOTH_SURVIVING+BATCH_BOTH_SURVIVING))
	FWD_SURVIVING=$((FWD_SURVIVING+BATCH_FWD_SURVIVING))
	REV_SURVIVING=$((REV_SURVIVING+BATCH_REV_SURVIVING))
	DROPPED=$((DROPPED+BATCH_DROPPED))
done


echo "Total input pairs: "$READ_PAIRS > $OUTPUT_FILE
echo "Both surviving: "$BOTH_SURVIVING  >> $OUTPUT_FILE
echo "Forward only surviving: "$FWD_SURVIVING  >> $OUTPUT_FILE
echo "Reverse only surviving: " $REV_SURVIVING  >> $OUTPUT_FILE
echo "Dropped: "$DROPPED >> $OUTPUT_FILE



AWK_HISTO_SCRIPT="/ngs_share/tools/awk_scripts/histbin.awk"

#COVERED=`wc -l $METH_CALL_FILE`
#echo "Covered (strand-specific) CpGs: " $COVERED > $OUTPUT_FILE
#AVG_DEPTH=`
#echo "Average depth: " $AVG_DEPTH >> $OUTPUT_FILE

for report in $trim_reports
do
	cat $report| cut -d' ' -f2|  gawk -f $AWK_HISTO_SCRIPT 1 0 150 150 ${report%.txt}_covg_hist.txt -
done
