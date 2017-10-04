library(RnBeads)

pipeline0_output<-"/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/results/encode_wgbs_orig"

pipeline1_output<-"/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/results/encode_wgbs_seqcap_full/chr22/"

pipeline2_output<-"/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/results/encode_wgbs/output"

pipeline3_output<-"/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/results/encode_wgbs_orig_rerun"

pipeline4_output<-"/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/results/encode_wgbs_cwl"


rnb.options(strand.specific=TRUE)

OUT_DIR<-"/ngs_share/scratch/benchmark/encode_chr22_test/rnb.sets"

### PREPROCESSING of the ENCODE data
# /opt/miniconda/bin/liftOver -bedPlus=4 ENCFF333EXV.bg hg38ToHg19.over.chain.gz ENCFF333EXV.hg19.bg unlifted.bed
# cat ENCFF333EXV.hg19.bg | /cbl/tools/bin/bedtools sort > ENCFF333EXV.hg19.sorted.bg
# cat ENCFF333EXV.hg19.sorted.bg | grep -v "\.\s0" > ENCFF333EXV.hg19.sorted.filtered.bg
# cat ENCFF333EXV.hg19.sorted.filtered.bg | /cbl/tools/bin/bedtools groupby -g 1,2,3,6 -c 5,10,11 -o sum,sum,mean > ENCFF333EXV.hg19.smr.bg
# cat ENCFF333EXV.hg19.smr.bg | grep -e "^chr22" > ENCFF333EXV.hg19.smr.chr22.bg

NROWS=100000
rnb.set.p0<-read.bed.files(base.dir=NULL,
					file.names=file.path(pipeline0_output, "ENCFF333EXV.hg19.chr22.smr.bg"),
					pos.coord.shift=1L,
					skip.lines=1L,
					chr.col=1L,
					start.col=2L,
					end.col=3L,
					c.col=NA,
					t.col=NA,
					strand.col=4L,
					mean.meth.col=7L,
					coverage.col=6L,
					coord.shift=0L,
					#nrows=NROWS,
					verbose=TRUE)
			
rnb.set.p0@pheno$Sample_Name<-"ENCFF333EXV"

##filter on chr22
#ann0<-annotation(rnb.set.p0)
#not_chr22<-which(ann0$Chromosome != "chr22")
#rnb.set.p0.chr22<-remove.sites(not_chr22, rnb.set.p0)

save.rnb.set(rnb.set.p0, path=file.path(OUT_DIR, "rnb.set_ENCODE"))

rnb.set.p1<-read.bed.files(base.dir=NULL, 
					file.names=file.path(pipeline1_output, "chr22.cpg.filtered.strand..6plus2.bed"),
					pos.coord.shift=1L,
					skip.lines=1L,
					chr.col=1L,
					start.col=2L,
					end.col=3L,
					c.col=NA,
					t.col=NA,
					strand.col=6L,
					mean.meth.col=7L,
					coverage.col=8L,
					coord.shift=0L,
					#nrows=NROWS,
					verbose=TRUE)

rnb.set.p1@pheno$Sample_Name<-"ENCFF333EXV"
			
#low.cov.sites<-which(rowSums(covg(rnb.set.p1)<5)>0)

#rnb.set.p1.f<-remove.sites(rnb.set.p1, low.cov.sites)

ann1<-annotation(rnb.set.p1)
not_chr22<-which(ann1$Chromosome != "chr22")
rnb.set.p1.chr22<-remove.sites(rnb.set.p1, not_chr22)


save.rnb.set(rnb.set.p1.chr22, path=file.path(OUT_DIR, "rnb.set_RocheSeqCap"))
			
rnb.set.p2<-read.bed.files(base.dir=NULL,
						file.names=file.path(pipeline2_output, "ENCLB098BGY_pe_unsorted_mkdup.bismark.cov.gz"),
						skip.lines=0,
						chr.col=1L,
						start.col=2L,
						end.col=NA,
						c.col=5L,
						t.col=6L,
						strand.col=NA,
						mean.meth.col=NA,
						coverage.col=NA,
						coord.shift = 0L,
						#nrows=NROWS,
						verbose=TRUE)

rnb.set.p2@pheno$Sample_Name<-"ENCFF333EXV"

ann2<-annotation(rnb.set.p2)
not_chr22<-which(ann2$Chromosome != "chr22")
rnb.set.p2.chr22<-remove.sites(rnb.set.p2, not_chr22)

save.rnb.set(rnb.set.p2.chr22, path=file.path(OUT_DIR, "rnb.set_Toth"))


###


rnb.set.p3<-read.bed.files(base.dir=NULL,
		file.names=file.path(pipeline3_output, "chr22_1.fastq.trimmed_bismark_bt2_pe.bismark.cov"),
		skip.lines=0,
		chr.col=1L,
		start.col=2L,
		end.col=NA,
		c.col=5L,
		t.col=6L,
		strand.col=NA,
		mean.meth.col=NA,
		coverage.col=NA,
		coord.shift = 0L,
		#nrows=NROWS,
		verbose=TRUE)

rnb.set.p3@pheno$Sample_Name<-"ENCFF333EXV"

ann3<-annotation(rnb.set.p3)
not_chr22<-which(ann3$Chromosome != "chr22")
rnb.set.p3.chr22<-remove.sites(rnb.set.p3, not_chr22)

save.rnb.set(rnb.set.p3.chr22, path=file.path(OUT_DIR, "rnb.set_ENCODE_local"))

###


rnb.set.p4<-read.bed.files(base.dir=NULL,
		file.names=file.path(pipeline4_output, "methcalls_CpG.bedGraph"),
		skip.lines=0,
		chr.col=1L,
		start.col=2L,
		end.col=3L,
		c.col=5L,
		t.col=6L,
		strand.col=NA,
		mean.meth.col=NA,
		coverage.col=NA,
		coord.shift = 1L,
		#nrows=NROWS,
		verbose=TRUE)

rnb.set.p4@pheno$Sample_Name<-"ENCFF333EXV"

ann4<-annotation(rnb.set.p4)
not_chr22<-which(ann4$Chromosome != "chr22")
rnb.set.p4.chr22<-remove.sites(rnb.set.p4, not_chr22)

save.rnb.set(rnb.set.p4.chr22, path=file.path(OUT_DIR, "rnb.set_CWL"))




				
				
				
				

				
				