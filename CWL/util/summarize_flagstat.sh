#!/bin/sh
#
#

flagstat_files=`ls -1 | grep $1.flagStat`

OUTPUT_FILE="flagstat_$1_summary.txt"

RECORDS[1]="in total (QC-passed reads + QC-failed reads)"
RECORDS[2]="secondary"
RECORDS[3]="supplementary"
RECORDS[4]="duplicates"
RECORDS[5]="mapped ("
RECORDS[6]="paired in sequencing"
RECORDS[7]="read1"
RECORDS[8]="read2"
RECORDS[9]="properly paired"
RECORDS[10]="with itself and mate mapped\\$"
RECORDS[11]="singletons"
RECORDS[12]="with mate mapped to a different chr\\$"
RECORDS[13]="with mate mapped to a different chr (mapQ>=5)"

for i in `seq 1 13`
do
     DATA_1[$i]=0
     DATA_2[$i]=0
done

for ff in $flagstat_files
do
     for i in `seq 1 13`
     do
        rec_batch_1=`cat $ff | grep -e "${RECORDS[$i]}" | sed "s|\([0-9]*\)\s+\s\([0-9]*\)\s${RECORDS[$i]}.*|\1|g"`
        rec_batch_2=`cat $ff | grep -e "${RECORDS[$i]}" | sed "s|\([0-9]*\)\s+\s\([0-9]*\)\s${RECORDS[$i]}.*|\2|g"`
        
        DATA_1[$i]=$((DATA_1[i]+rec_batch_1))
        DATA_2[$i]=$((DATA_2[i]+rec_batch_2))
          
     done
done

for i in `seq 1 13`
do
    if [ $i -eq 5 ]
    then
        if [ ${DATA_1[5]} -ne 0 ]
        then
            perc1=`echo 100*${DATA_1[$i]}/${DATA_1[1]} | bc`
        else
            perc2=0
        fi
        if [ ${DATA_2[5]} -ne 0 ]
        then
            perc2=`echo 100*${DATA_2[$i]}/${DATA_2[1]} | bc`
        else
            perc2=0
        fi
        perc1_form=`printf "%.2f" "$perc1"`
        perc2_form=`printf "%.2f" "$perc2"`
        echo ${DATA_1[$i]}" + "${DATA_2[$i]}" "${RECORDS[$i]} $perc1_form"%:" $perc2_form"%)"| sed -e 's/\\\$//g' >> $OUTPUT_FILE
    elif [ $i -eq 9 ]
    then
        if [ ${DATA_1[6]} -ne 0 ]
        then
            perc1=`echo 100*${DATA_1[$i]}/${DATA_1[6]} | bc`
        else
            perc1=0
        fi
        if [ ${DATA_2[6]} -ne 0 ]
        then
            perc2=`echo 100*${DATA_2[$i]}/${DATA_2[6]} | bc`
        else
            perc2=0
        fi
        perc1_form=`printf "%.2f" "$perc1"`
        perc2_form=`printf "%.2f" "$perc2"`
        echo ${DATA_1[$i]}" + "${DATA_2[$i]}" "${RECORDS[$i]}" (" $perc1_form"%:" $perc2_form"%)"| sed -e 's/\\\$//g' >> $OUTPUT_FILE
    elif [ $i -eq 11 ]
    then
        if [ ${DATA_1[5]} -ne 0 ]
        then
            perc1=`echo 100*${DATA_1[$i]}/${DATA_1[5]} | bc`
        else
            perc1=0
        fi
        if [ ${DATA_2[5]} -ne 0 ]
        then
            perc2=`echo 100*${DATA_2[$i]}/${DATA_2[5]} | bc`
        else
            perc2=0
        fi
        perc1_form=`printf "%.2f" "$perc1"`
        perc2_form=`printf "%.2f" "$perc2"`
        echo ${DATA_1[$i]}" + "${DATA_2[$i]}" "${RECORDS[$i]}" (" $perc1_form"%:" $perc2_form"%)"| sed -e 's/\\\$//g' >> $OUTPUT_FILE
    else 
        echo ${DATA_1[$i]}" + "${DATA_2[$i]}" "${RECORDS[$i]}| sed -e 's/\\\$//g' >> $OUTPUT_FILE
    fi
done

