#!/bin/sh
#
#

METH_CALL_FILE=$1
OUTPUT_FILE="coverage_summary.txt"

AWK_HISTO_SCRIPT="/ngs_share/tools/awk_scripts/histbin.awk"

#COVERED=`wc -l $METH_CALL_FILE`
#echo "Covered (strand-specific) CpGs: " $COVERED > $OUTPUT_FILE
#AVG_DEPTH=`
#echo "Average depth: " $AVG_DEPTH >> $OUTPUT_FILE

cat $METH_CALL_FILE| cut -f5,6| sed "s/\s/+/g" | bc | awk '{f += $1;next} END{printf("Covered (strand-specific) CpGs: %.0d\nAverage depth of coverage: %.3g",NR, f/NR)}' > $OUTPUT_FILE

cat $METH_CALL_FILE| cut -f5,6| sed "s/\s/+/g" | bc | gawk -f $AWK_HISTO_SCRIPT 1 0 1000 1000 ${METH_CALL_FILE%.bedGraph}_covg_hist.dat -
