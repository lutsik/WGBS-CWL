#!/bin/bash
# dme-align-se.sh - align se reads with bismark/bowtie

main() {
    # If available, will print tool versions to stderr and json string to stdout
    versions=''
    if [ -f /usr/bin/tool_versions.py ]; then 
        index_file=`dx describe "$dme_ix" --name`
        if [[ $index_file =~ *"bowtie2"* ]]; then
            versions=`tool_versions.py --applet dme-align-se-bowtie2`
        else
            versions=`tool_versions.py --dxjson dnanexus-executable.json`
        fi
    fi

    echo "* Value of reads:     '${reads[@]}'"
    echo "* Value of dme_ix:    '$dme_ix'"
    echo "* Value of ncpus:      $ncpus"

    # NOTE: dme-align produces *_techrep_bismark.bam and dme-extract merges 1+ techrep bams into a *_bismark_biorep.bam.
    #       The reason for the name 'word' order is so thal older *_bismark.bam alignments are recognizable as techrep bams

    # NOTE: not expecting an array of files, but supporting it nonetheless.
    # load and concat reads
    outfile_name=""
    concat=""
    rm -f concat.fq
    for ix in ${!reads[@]}
    do
        file_root=`dx describe "${reads[$ix]}" --name`
        file_root=${file_root%.fastq.gz}
        file_root=${file_root%.fq.gz}
        if [ "${outfile_name}" == "" ]; then
            outfile_name="${file_root}"
        else
            outfile_name="${file_root}_${outfile_name}"
            if [ "${concat}" == "" ]; then
                outfile_name="${outfile_name}_concat" 
                concat="s concatenated as"
            fi
        fi
        echo "* Downloading and concatenating ${file_root}.fq.gz file..."
        dx download "${reads[$ix]}" -o - | gunzip >> concat.fq
    done
    # Try to simplify the names
    rep_root=""
    if [ -f /usr/bin/parse_property.py ]; then
        rep_root=`parse_property.py --job "${DX_JOB_ID}" --root_name --quiet`
    fi
    if [ "$rep_root" != "" ]; then
        outfile_name="${rep_root}_reads"
    else
        outfile_name="${outfile_name}_reads"
    fi
    mv concat.fq ${outfile_name}.fq
    #echo "* Gzipping file..."
    #gzip ${outfile_name}.fq
    reads_root=${outfile_name}
    echo "* Fastq${concat} file: '${reads_root}.fq'"
    ls -l ${reads_root}.fq

    echo "* Download index archive..."
    dx download "$dme_ix" -o index.tgz

    bam_root="${reads_root}_techrep"
    # Try to simplify the names
    if [ "$rep_root" != "" ]; then
        bam_root="${rep_root}_techrep"
    fi

    echo "* ===== Calling DNAnexus and ENCODE independent script... ====="
    set -x
    dname_align_se.sh index.tgz ${reads_root}.fq $ncpus $bam_root
    set +x
    echo "* ===== Returned from dnanexus and encodeD independent script ====="
    bam_root="${bam_root}_bismark"

    echo "* Prepare metadata..."
    qc_stats=''
    reads=0
    read_len=0
    if [ -f /usr/bin/qc_metrics.py ]; then
        qc_stats=`qc_metrics.py -n bismark_map -f ${bam_root}_map_report.txt`
        meta=`qc_metrics.py -n samtools_flagstats -f ${bam_root}_flagstat.txt`
        qc_stats=`echo $qc_stats, $meta`
        reads=`qc_metrics.py -n samtools_flagstats -f ${bam_root}_flagstat.txt -k total`
        meta=`qc_metrics.py -n samtools_stats -d ':' -f ${bam_root}_samstats_summary.txt`
        read_len=`qc_metrics.py -n samtools_stats -d ':' -f ${bam_root}_samstats_summary.txt -k "average length"`
        qc_stats=`echo $qc_stats, $meta`
    fi
    # All qc to one file:
    cat ${bam_root}_map_report.txt      >> ${bam_root}_qc.txt
    echo " "                            >> ${bam_root}_qc.txt
    echo "===== samtools flagstat =====" > ${bam_root}_qc.txt
    cat ${bam_root}_flagstat.txt        >> ${bam_root}_qc.txt
    echo " "                            >> ${bam_root}_qc.txt
    echo "===== samtools stats ====="   >> ${bam_root}_qc.txt
    cat ${bam_root}_samstats.txt        >> ${bam_root}_qc.txt

    echo "* Upload results..."
    ls -l /home/dnanexus/output
    bam_techrep=$(dx upload ${bam_root}.bam --details "{ $qc_stats }" --property SW="$versions" \
                                            --property reads="$reads" --property read_length="$read_len" --brief)
    bam_techrep_qc=$(dx upload ${bam_root}_qc.txt --details "{ $qc_stats }" --property SW="$versions" --brief)
    map_techrep=$(dx upload ${bam_root}_map_report.txt --details "{ $qc_stats }" --property SW="$versions" --brief)

    dx-jobutil-add-output bam_techrep "$bam_techrep" --class=file
    dx-jobutil-add-output bam_techrep_qc "$bam_techrep_qc" --class=file
    dx-jobutil-add-output map_techrep "$map_techrep" --class=file

    dx-jobutil-add-output reads "$reads" --class=string
    dx-jobutil-add-output metadata "{ $qc_stats }" --class=string

    echo "* Finished."
 }