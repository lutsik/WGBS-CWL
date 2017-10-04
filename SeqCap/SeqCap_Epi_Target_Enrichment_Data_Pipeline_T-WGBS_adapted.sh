#!/bin/bash 
set -x
########! SeqCap Epi Target Enrichment Data Pipeline !########

DATADIR=$1
OUTPUTDIR=$2
FILE1_TOKEN="_R1"
FILE2_TOKEN="_R2"

# FASTA file with adapter sequences
#ADAPTER_FILE=/opt/bioinfo/Trimmomatic-0.36/adapters/ATAC_common.fa
ADAPTER_FILE=/opt/bioinfo/Trimmomatic-0.36/adapters/NexteraPE-PE.fa


#Number of processors
NUM_PRO="4"
#File containing SNP information
#SNP_INFO="/cbl/bcbio/genomes/Hsapiens/GRCh37/variation/dbsnp_138.vcf"
SNP_INFO="/cbl/scratch/data/dbsnp_138.vcf"
#File containing reference sequence hg19
#REF_SEQ="/cbl/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.fa"
#REF_SEQ="/cbl/scratch/data/hg19.capseq.fa"
REF_SEQ="/cbl/scratch/data/GRCh37.lambda.fa"
#File containing capture targets 
CAP_TAR="/cbl/scratch/data/ref-transcripts.bed"
#File containing capture targets without header
CAP_TAR_WH="/cbl/bcbio/genomes/Hsapiens/GRCh37/rnaseq/ref-transcripts.bed"
#File containing chromosome_sizes 
#CHR_SIZE="/projects/Twins_MS_EPI/Test/chromosome_sizes.txt"
CHR_SIZE="/cbl/bcbio/genomes/Hsapiens/GRCh37/seq/GRCh37.chrom.sizes"
cd $DATADIR
filenames=`ls -m1 *${FILE1_TOKEN}.fastq.gz`

if [ ! -e $OUTPUTDIR ]; then
	mkdir $OUTPUTDIR
fi

cd $OUTPUTDIR
for filename in $filenames
do

#### CHANGE THE FILE NAME TOKEN!!!!!!!!
SAMPLENAME=${filename%_R1.fastq.gz}
echo $SAMPLENAME
mkdir $OUTPUTDIR/$SAMPLENAME
cd $OUTPUTDIR/$SAMPLENAME


#1!Compressed FASTQ files (.gz extension) need to be decompressed
echo "====================1. Compressed FASTQ files (.gz extension) need to be decompressed===================="
gunzip -c $DATADIR/${SAMPLENAME}${FILE1_TOKEN}.fastq.gz > ${SAMPLENAME}${FILE1_TOKEN}.fastq
gunzip -c $DATADIR/${SAMPLENAME}${FILE2_TOKEN}.fastq.gz > ${SAMPLENAME}${FILE2_TOKEN}.fastq


#2!Create fastQC files of all fastq files in the working directory!
echo "====================2. Create fastQC files of all fastq files in the working directory===================="
/opt/bioinfo/FastQC/fastqc --nogroup *.fastq


#3!Peform adaptor and quality trimming on all files in the output!
echo "====================3. Peform adaptor and quality trimming on all files in the output===================="
/opt/bioinfo/jre1.7.0_79/bin/java -Xms4g -Xmx4g -jar /opt/bioinfo/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads $NUM_PRO -phred33 \
${SAMPLENAME}${FILE1_TOKEN}.fastq ${SAMPLENAME}${FILE2_TOKEN}.fastq \
${SAMPLENAME}${FILE1_TOKEN}_trimmed.fq ${SAMPLENAME}${FILE1_TOKEN}_unpaired.fq \
${SAMPLENAME}${FILE2_TOKEN}_trimmed.fq ${SAMPLENAME}${FILE2_TOKEN}_unpaired.fq \
ILLUMINACLIP:${ADAPTER_FILE}:	 LEADING:0 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:20

#4!Create fastQC files of all trimmed.fq files in the working directory!
echo "====================4. Create fastQC files of all trimmed.fq files in the working directory===================="
/opt/bioinfo/FastQC/fastqc --nogroup *_trimmed.fq


#5!Mapping reads using BSMAP
echo "====================5. Mapping reads using BSMAP===================="
/opt/bioinfo/bsmap-2.74/bsmap -r 0 -s 15 -n 1 -a ${SAMPLENAME}${FILE1_TOKEN}_trimmed.fq \
-b ${SAMPLENAME}${FILE2_TOKEN}_trimmed.fq -d $REF_SEQ -p $NUM_PRO -o ${SAMPLENAME}.sam 


#6!Add Read Group and Convert to BAM
echo "====================6. Add Read Group and Convert to BAM===================="
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -Xms20g -jar /opt/bioinfo/picard-tools-1.120/AddOrReplaceReadGroups.jar VALIDATION_STRINGENCY=LENIENT \
INPUT=${SAMPLENAME}.sam OUTPUT=${SAMPLENAME}.bam CREATE_INDEX=TRUE RGID=${SAMPLENAME} \
RGLB=${SAMPLENAME} RGPL=illumina RGSM=${SAMPLENAME} RGPU=11


#7!Check number of mapped reads using flagstat
echo "====================7. Check number of mapped reads using flagstat===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools flagstat ${SAMPLENAME}.bam > ${SAMPLENAME}_flagstat1.txt 


#Sorting an removing duplicates
#8!Split BAM files
echo "====================8. Split BAM files===================="
/opt/bioinfo/bamtools/bin/bamtools split -tag ZS -in ${SAMPLENAME}.bam


#9!Merge strand BAM files 
echo "====================9. Merge strand BAM files===================="
/opt/bioinfo/bamtools/bin/bamtools merge -in ${SAMPLENAME}.TAG_ZS_++.bam -in ${SAMPLENAME}.TAG_ZS_+-.bam -out ${SAMPLENAME}.top.bam
/opt/bioinfo/bamtools/bin/bamtools merge -in ${SAMPLENAME}.TAG_ZS_-+.bam -in ${SAMPLENAME}.TAG_ZS_--.bam -out ${SAMPLENAME}.bottom.bam


#10!Sort BAM files
echo "====================10. Sort BAM files===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools sort ${SAMPLENAME}.top.bam -o ${SAMPLENAME}.top.sorted.bam
/opt/bioinfo/samtools/samtools-1.3.1/samtools sort ${SAMPLENAME}.bottom.bam -o ${SAMPLENAME}.bottom.sorted.bam


#11!Remove Duplicates
echo "====================11. Remove Duplicates===================="
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx4g -Xms4g -jar /opt/bioinfo/picard-tools-1.120/MarkDuplicates.jar VALIDATION_STRINGENCY=LENIENT \
INPUT=${SAMPLENAME}.top.sorted.bam OUTPUT=${SAMPLENAME}.top.rmdups.bam METRICS_FILE=${SAMPLENAME}.top.rmdups_metrics.txt \
REMOVE_DUPLICATES=true ASSUME_SORTED=true CREATE_INDEX=true

/opt/bioinfo/jre1.7.0_79/bin/java -Xmx4g -Xms4g -jar /opt/bioinfo/picard-tools-1.120/MarkDuplicates.jar VALIDATION_STRINGENCY=LENIENT \
INPUT=${SAMPLENAME}.bottom.sorted.bam OUTPUT=${SAMPLENAME}.bottom.rmdups.bam METRICS_FILE=${SAMPLENAME}.bottom.rmdups_metrics.txt \
REMOVE_DUPLICATES=true ASSUME_SORTED=true CREATE_INDEX=true


#12!Merge duplicate removed BAM files
echo "====================12. Merge duplicate removed BAM files===================="
/opt/bioinfo/bamtools/bin/bamtools merge -in ${SAMPLENAME}.top.rmdups.bam -in ${SAMPLENAME}.bottom.rmdups.bam -out ${SAMPLENAME}.rmdups.bam


#13!Check number of mapped reads using flagstat
echo "====================13. Check number of mapped reads using flagstat===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools flagstat ${SAMPLENAME}.rmdups.bam > ${SAMPLENAME}_flagstat2.txt 


#14!Filter BAM file to keep only mapped and properly paired reads
echo "====================14. Filter BAM file to keep only mapped and properly paired reads===================="
/opt/bioinfo/bamtools/bin/bamtools filter -isMapped true -isPaired true -isProperPair true -forceCompression \
-in ${SAMPLENAME}.rmdups.bam -out ${SAMPLENAME}.filtered.bam 


#15!Clip overlapping reads
echo "====================15. Clip overlapping reads===================="
/opt/bioinfo/bamUtil_1.0.13/bamUtil/bin/bam clipoverlap --stats --in ${SAMPLENAME}.filtered.bam --out ${SAMPLENAME}.clipped.bam


#16!Indexing BAM files
echo "====================16. Indexing BAM files===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools index ${SAMPLENAME}.clipped.bam 


#17!Check number of mapped reads using flagstat
/opt/bioinfo/samtools/samtools-1.3.1/samtools flagstat ${SAMPLENAME}.clipped.bam > ${SAMPLENAME}_flagstat3.txt 


#18!Calculate BAsic Mapping Metrics 
echo "====================18. Calculate Basic Mapping Metrics===================="
#(https://web.archive.org/web/20131024020536/http://picard.sourceforge.net/picard-metric-definitions.shtml#AlignmentSummaryMetrics)
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx4g -Xms4g -jar /opt/bioinfo/picard-tools-1.120/CollectAlignmentSummaryMetrics.jar METRIC_ACCUMULATION_LEVEL=ALL_READS \
INPUT=${SAMPLENAME}.clipped.bam OUTPUT=${SAMPLENAME}_picard_alignment_metrics.txt REFERENCE_SEQUENCE=$REF_SEQ VALIDATION_STRINGENCY=LENIENT


#19!Estimate Insert Size distribution
echo "====================19. Estimate Insert Size distribution===================="
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx4g -jar /opt/bioinfo/picard-tools-1.120/CollectInsertSizeMetrics.jar VALIDATION_STRINGENCY=LENIENT \
HISTOGRAM_FILE=${SAMPLENAME}_picard_insert_size_plot.pdf INPUT=${SAMPLENAME}.filtered.bam OUTPUT=${SAMPLENAME}_picard_insert_size_metrics.txt


#20!Create a Picard Interval List Header
echo "====================20. Create a Picard Target Interval list===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools view -H ${SAMPLENAME}.bam > ${SAMPLENAME}_bam_header.txt 


#21!Create a Picar:d Target Interval List Body (immune_BOTH_primary_targets.bed is a bed file containing coverage targets) 
#First the 1st line from the immune_BOTH_primary_targets.bed file is removed (line says: #track name=target_region description="Target Regions")
#then the first column is printed, followed by a tab, to the second column the value 1 is summed to the values, followed by a tab, 
#then third column is printed, followed by a tab, then a forth column is produced which says +, followed by a tab, 
#then a fifth column is produced which says interval_1 etc"
echo "====================21. Create a Picar:d Target Interval List Body (immune_BOTH_primary_targets.bed is a bed file containing coverage targets)===================="
cat $CAP_TAR | tail -n +2 | gawk '{print $1 "\t" $2+1 "\t" $3 "\t+\tinterval_" NR}' > immune_BOTH_primary_targets_body.txt


#22!Concatenate to Create a Picard Target Interval List
echo "====================22. Concatenate to Create a Picard Target Interval List===================="
cat ${SAMPLENAME}_bam_header.txt immune_BOTH_primary_targets_body.txt > immune_BOTH_primary_target_intervals.txt


#23!Hybrid Selection Analysis Metrics calculates a number of metrics assessing the quality of targeted enrichment reads.
#CalculateHsMetrics of Picard only works when the reads have the operator (M|I|D|N) in CIGAR: 
#Here the reads without (M|I|D|N) are extracted
echo "====================23. Hybrid Selection Analysis Metrics calculates a number of metrics assessing the quality of targeted enrichment reads.===================="
/opt/bioinfo/samtools/samtools-1.3.1/samtools view ${SAMPLENAME}.clipped.bam | awk '$6!~/[MDIN]/ {print $1}' > ${SAMPLENAME}.clipped.badId

#In the next step the reads without (M|I|D|N) are removed from the clipped.bam file
/opt/bioinfo/samtools/samtools-1.3.1/samtools view ${SAMPLENAME}.clipped.bam | grep -vwFf ${SAMPLENAME}.clipped.badId \
| cat <(/opt/bioinfo/samtools/samtools-1.3.1/samtools view -H ${SAMPLENAME}.clipped.bam) - | \
/opt/bioinfo/samtools/samtools-1.3.1/samtools view -bS - > ${SAMPLENAME}.clipped.clean.bam

#Hybrid Selection Analysis Metrics (https://broadinstitute.github.io/picard/picard-metric-definitions.html)
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -Xms20g -jar /opt/bioinfo/picard-tools-1.120/CalculateHsMetrics.jar \
BAIT_INTERVALS=immune_BOTH_primary_target_intervals.txt TARGET_INTERVALS=immune_BOTH_primary_target_intervals.txt \
INPUT=${SAMPLENAME}.clipped.clean.bam OUTPUT=${SAMPLENAME}_picard_hs_metrics.txt \
METRIC_ACCUMULATION_LEVEL=ALL_READS REFERENCE_SEQUENCE=$REF_SEQ VALIDATION_STRINGENCY=LENIENT TMP_DIR=. CREATE_INDEX=true


#24!Add padding (100 bp each side) to targets to assess off-target reads that are adjacent to the targets
#pad, sort and merge overlapping and book-ended regions
echo "====================24. Add padding (100 bp each side) to targets to assess off-target reads that are adjacent to the targets===================="
/opt/bioinfo/bedtools2/bin/slopBed -i $CAP_TAR_WH -b 100 \
-g $CHR_SIZE | /opt/bioinfo/bedtools2/bin/sortBed -i - | \
/opt/bioinfo/bedtools2/bin/mergeBed -i - > immune_BOTH_primary_padded_targets.bed


#25!Determine Sum Total Size of Regions in a BED file
echo "====================25. Determine Sum Total Size of Regions in a BED file===================="
/opt/bioinfo/bedtools2/bin/genomeCoverageBed -i $CAP_TAR -g $CHR_SIZE \
-max 1 | grep -P "genome\t1" | cut -f 3 > TotalSumSizeBedFileRegions.txt


#26!Count on-target reads
echo "====================26. Count on-target reads===================="
/opt/bioinfo/bedtools2/bin/intersectBed -bed -abam ${SAMPLENAME}.clipped.bam -b $CAP_TAR_WH > CountOntargetReads.txt


#27!Calculate Coverage Depth
#GATK requires a .dict file which can be created as follows 
#i.e. (/opt/bioinfo/jre1.7.0_79/bin/java -jar /opt/bioinfo/picard-tools-1.120/CreateSequenceDictionary.jar R=$REF_SEQ O=/projects/references/hg19.capseq.dict)
#echo "====================27. Calculate coverage depth in target regions ===================="
#/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -Xms20g -jar /opt/bioinfo/GATK/GenomeAnalysisTK.jar -T DepthOfCoverage -R $REF_SEQ \
#-I ${SAMPLENAME}.clipped.bam -o ${SAMPLENAME}_gatk_target_coverage -L $CAP_TAR_WH -ct 1 -ct 10 -ct 20 -ct 30 #\
#--num_threads 1 --num_cpu_threads_per_data_thread 1

echo "====================27. Generate coverage track ===================="
/opt/bioinfo/bedtools2/bin/bedtools genomecov -ibam ${SAMPLENAME}.rmdups.bam -bg > ${SAMPLENAME}_genome_coverage.bg


#28!Determine methylation percentage using BSMAP
#Determines methylation at each C base in the sample. "-m 1" means minimum coverage of 1.
echo "====================28. Determine methylation percentage using BSMAP===================="
python /opt/bioinfo/bsmap-2.74/methratio.py -d $REF_SEQ \
-s /opt/bioinfo/samtools/samtools-1.3.1 -m 1 -z -i skip -o ${SAMPLENAME}.methylation_results.txt ${SAMPLENAME}.clipped.bam


#29!Determine bisulfite conversion efficiency using BSMAP 
#see for output details http://sr320.tumblr.com/post/51475005119
#echo "====================29. Determine bisulfite conversion efficiency using BSMAP===================="
#python /opt/bioinfo/bsmap-2.74/methratio.py -d $REF_SEQ \
#-s /opt/bioinfo/samtools/samtools-1.3.1 -m 1 -z -i skip -c lambda -o ${SAMPLENAME}.lambda.methylation_results.txt ${SAMPLENAME}.clipped.bam


#30!Determine bisulfite conversion efficiency using BSMAP 
#see for output details http://sr320.tumblr.com/post/51475005119
echo "====================30. Determine bisulfite conversion efficiency using BSMAP===================="
python /opt/bioinfo/bsmap-2.74/methratio.py -d $REF_SEQ \
-s /opt/bioinfo/samtools/samtools-1.3.1 -m 1 -z -i skip -c lambda -o ${SAMPLENAME}.lambda.methylation_results.txt ${SAMPLENAME}.clipped.bam

#calculate conversion rate
cat ${SAMPLENAME}.lambda.methylation_results.txt |
awk '{ print $2 "\t" $7 "\t" $8}' > ${SAMPLENAME}.cap.lambda.methylation_results.txt
#awk '$2 >=4500&& $2<=6500 { print $2 "\t" $7 "\t" $8}' > ${SAMPLENAME}.cap.lambda.methylation_results.txt

cat ${SAMPLENAME}.cap.lambda.methylation_results.txt |
awk '{SUM1 += $2; SUM2 +=$3}  END {print 1-SUM1/SUM2}' > ${SAMPLENAME}.cap.lambda.conversionrate.txt


#31!Combined SNP methylation calling using BisSNP
#Base Quality Recalibration
echo "====================31. Combined SNP methylation calling using BisSNP===================="
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -jar /opt/bioinfo/BisSNP/BisSNP-0.82.2.jar -R $REF_SEQ -I ${SAMPLENAME}.clipped.bam \
-T BisulfiteCountCovariates -cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate \
-recalFile ${SAMPLENAME}.recalFile_before.csv -nt $NUM_PRO -knownSites $SNP_INFO #-trim5 9 -trim3 9

/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -jar /opt/bioinfo/BisSNP/BisSNP-0.82.2.jar -R $REF_SEQ -I ${SAMPLENAME}.clipped.bam \
-o ${SAMPLENAME}.recal.bam -T BisulfiteTableRecalibration -recalFile ${SAMPLENAME}.recalFile_before.csv -maxQ 40 #-trim5 5 -trim3 5

#Combined SNP/methylation calling
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -jar /opt/bioinfo/BisSNP/BisSNP-0.82.2.jar -R $REF_SEQ -I ${SAMPLENAME}.recal.bam \
-T BisulfiteGenotyper -D $SNP_INFO -vfn1 ${SAMPLENAME}.cpg.raw.vcf -vfn2 ${SAMPLENAME}.snp.raw.vcf \
-stand_call_conf 20 -stand_emit_conf 0 -mmq 30 -mbq 0 -nt $NUM_PRO #-trim5 5 -trim3 5
#-L $CAP_TAR_WH -stand_call_conf 20 -stand_emit_conf 0 -mmq 30 -mbq 0 -nt $NUM_PRO #-trim5 5 -trim3 5

#Sort VCF Files
perl /opt/bioinfo/BisSNP/Utils/sortByRefAndCor.pl --k 1 --c 2 ${SAMPLENAME}.snp.raw.vcf $REF_SEQ.fai > ${SAMPLENAME}.snp.raw.sorted.vcf 
perl /opt/bioinfo/BisSNP/Utils/sortByRefAndCor.pl --k 1 --c 2 ${SAMPLENAME}.cpg.raw.vcf $REF_SEQ.fai > ${SAMPLENAME}.cpg.raw.sorted.vcf  

# Filter SNP/methylation calls
/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -jar /opt/bioinfo/BisSNP/BisSNP-0.82.2.jar -R $REF_SEQ -T VCFpostprocess \
-oldVcf ${SAMPLENAME}.snp.raw.sorted.vcf -newVcf ${SAMPLENAME}.snp.filtered.vcf \
-snpVcf ${SAMPLENAME}.snp.raw.sorted.vcf -o ${SAMPLENAME}.snp.filter.summary.txt #-trim5 5 -trim3 5

/opt/bioinfo/jre1.7.0_79/bin/java -Xmx20g -jar /opt/bioinfo/BisSNP/BisSNP-0.82.2.jar -R $REF_SEQ -T VCFpostprocess \
-oldVcf ${SAMPLENAME}.cpg.raw.sorted.vcf -newVcf ${SAMPLENAME}.cpg.filtered.vcf \
-snpVcf ${SAMPLENAME}.snp.raw.sorted.vcf -o ${SAMPLENAME}.cpg.filter.summary.txt #-trim5 5 -trim3 5

#Convert VCF to BED file
perl /opt/bioinfo/BisSNP/Utils/vcf2bed6plus2.strand.pl ${SAMPLENAME}.snp.filtered.vcf
perl /opt/bioinfo/BisSNP/Utils/vcf2bed6plus2.strand.pl ${SAMPLENAME}.cpg.filtered.vcf


done
cd $OUTPUTDIR

##END