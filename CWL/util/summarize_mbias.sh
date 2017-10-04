#!/bin/bash

paste -d "\t" chr{1..22}_merged_dupl_removed.bam_mbias.txt chrX_merged_dupl_removed.bam_mbias.txt  > merged_mbias.txt

echo "nMethylated" > mean_meth.txt
echo "nUnmethylated" > mean_umeth.txt

cut -f`seq -s ',' 4 5 114` merged_mbias.txt | tail -n +2| sed -e 's/\t/ + /g' | bc >> mean_meth.txt
cut -f`seq -s ',' 5 5 115` merged_mbias.txt | tail -n +2| sed -e 's/\t/ + /g' | bc >> mean_umeth.txt

cut -f1-3 merged_mbias.txt | paste -d "\t" - mean_meth.txt mean_umeth.txt > merged_mbias_summ.txt