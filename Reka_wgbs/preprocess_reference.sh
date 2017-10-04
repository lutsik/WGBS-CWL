#!/usr/bin/env bash

#be sure that the following programs are on your PATH:
#bismark
#bowtie1

#############tools

. ./tools.sh

#############arguments

for ((i=1;i<=$#;i++)); 
do
    if [ ${!i} = "--location" ] 
    then ((i++)) 
        location=${!i};  
    fi

done

#############preprocessing

${bismark_loc}/bismark_genome_preparation --path_to_bowtie ${bowtie_loc} ${location} 


