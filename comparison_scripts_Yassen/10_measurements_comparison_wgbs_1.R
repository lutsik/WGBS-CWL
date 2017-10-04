########################################################################################################################
## 10_measurements_comparison_1.R
## created: 2015-01-22
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Compares the measurements of RRBS and Infinium for those samples, for which all technologies were present.
########################################################################################################################
if(TRUE){
## L I B R A R I E S ###################################################################################################

suppressPackageStartupMessages(library(RnBeads))
theme_set(theme_bw())

## G L O B A L S #######################################################################################################

#DIR.DATASETS <- ifelse(.Platform$OS.type == "windows", "D:/Datasets", "/icgc/dkfzlsdf/analysis/assenov/Data")
#DIR.DATASETS <- paste0(DIR.DATASETS, "/Methylation")
DIR.RNBSETS <- '/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/rnb.sets'
DIR.DATASETS <-'/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/comparison'
## List of all supported chromosomes
SUPPORTED.CHROMOSOMES <- names(rnb.get.chromosomes("hg19"))

# Log file

LOG_FILE="/tmp/comparison.log"

## F U N C T I O N S ###################################################################################################

intersect.all <- function(sets) {
	if (length(sets) == 0) {
		return(NULL)
	}
	if (length(sets) == 1) {
		return(sets[[1]])
	}
	result <- sets[[1]]
	for (i in 2:length(sets)) {
		result <- intersect(result, sets[[i]])
	}
	result
}

## M A I N #############################################################################################################

setwd(DIR.DATASETS)
logger.start("Data Preparation", fname = LOG_FILE)

## ---------------------------------------------------------------------------------------------------------------------
## Load the available datasets

samples.covered <- list()
datasets <- list()

## Load the Infinium 450k data
rnb.options(disk.dump.big.matrices = FALSE, identifiers.column = "Sample_Name")
#background.methods <- c("none" = "BMIQ", "methylumi.noob" = "BC+BMIQ")
pipelines <- c("ENCODE", "ENCODE_local", "Toth", "RocheSeqCap", "CWL")
for (pipeline in pipelines) {
	#fname <- paste0("2015-01-19-Doping/data/rnb.set_", bg.method, ".RDS")
	fname<-file.path(DIR.RNBSETS, sprintf("rnb.set_%s.zip", pipeline))
	logger.validate.file(fname)
	rnb.set <- load.rnb.set(fname)
	sname <- paste("WGBS Pipeline", pipeline)
	samples.covered[[sname]] <- samples(rnb.set)
	datasets[[sname]] <- rnb.set
	logger.status(c("Loaded", length(samples(rnb.set)), "Infinium samples from", fname))
}
#rm(pipelines, pipeline, fname, rnb.set, sname)

### Load the RRBS data from Bocki
#rnb.options(identifiers.column = "ID")
#fname <- "2014-06-05-Doping-Human/data/rnb.set.unfiltered.RData"
#logger.validate.file(fname)
#load(fname) # -> rnb.set
#datasets[["RRBS CeMM"]] <- rnb.set
#samples.covered[["RRBS CeMM"]] <- samples(rnb.set)
#logger.status(c("Loaded", length(samples(rnb.set)), "RRBS samples from", fname))
#rm(fname, rnb.set)

## Count all common samples and search for these in the RRBS DKFZ dataset
samples.common <- intersect.all(samples.covered)
logger.info(c(length(samples.common), "samples are in common"))
#dir.base <- "2015-01-20-Doping/data"
#regex.sample <- "^(.+)\\.txt\\.gz$"
#fnames <- dir(dir.base, pattern = regex.sample)
#names(fnames) <- gsub(regex.sample, "\\1", fnames)
#samples.common <- intersect(samples.common, names(fnames))
#logger.status(c("Found", length(samples.common)))
if (length(samples.common) == 0) {
	logger.error("No samples to compare all technologies on")
}
#rm(intersect.all, regex.sample)

## Reduce the Illumina and RRBS CeMM datasets to the common samples
iis <- sapply(samples.covered, function(sds) { sapply(samples.common, function(sname) { which(sds == sname) }) })
if(is.null(dim(iis))){
	iis<-matrix(iis, ncol=length(iis), dimnames=list(NULL, names(samples.covered)))
}
locations <- list()
meth.data <- list()
coverages <- list()
for (sname in names(datasets)) {
	rnb.set <- datasets[[sname]]
	if (inherits(rnb.set, "RnBeadSet")) {
		rnb.options(identifiers.column = "Sample_Name")
		mm <- meth(rnb.set, row.names = TRUE)[, iis[, sname], drop = FALSE]
		i <- 1:nrow(mm)
		cvg <- NULL
	} else { # inherits(rnb.set, "RnBiseqSet")
		rnb.options(identifiers.column = "Sample_Name")
		mm <- meth(rnb.set)[, iis[, sname], drop = FALSE]
		i <- which(!apply(is.na(mm), 1, all))
		cvg <- covg(rnb.set)[, iis[, sname], drop = FALSE]
	}
	locations[[sname]] <- with(annotation(rnb.set)[i, ], paste0(Chromosome, ":", Start, ":", Strand))
	meth.data[[sname]] <- mm[i, , drop = FALSE]
	coverages[[sname]] <- cvg[i, , drop = FALSE]
	#rm(rnb.set, mm, i, cvg)
}
#rm(datasets, samples.covered, iis, sname)
#
#
### Load RRBS data from DKFZ per sample
#logger.start("RRBS DKFZ")
#rrbs.dkfz <- lapply(samples.common, function(sname) {
#		cnames.required <- c("chr" = "character", "pos" = "integer", "strand" = "character", "context" = "character",
#			"ratio" = "numeric", "C_count" = "integer", "CT_count" = "integer")
#		tbl <- read.delim(file.path(dir.base, fnames[sname]), quote = "", stringsAsFactors = FALSE)
#		logger.status(c("Loaded", nrow(tbl), "record(s) from", fnames[sname]))
#		if (!all(names(cnames.required) %in% colnames(tbl))) {
#			logger.error("Missing required columns")
#		}
##		print(sapply(tbl[-(1:4)], range))
#		if (!identical(sapply(tbl[names(cnames.required)], class), cnames.required)) {
#			logger.error("Unexpected column types")
#		}
#		tbl <- tbl[tbl$chr %in% SUPPORTED.CHROMOSOMES & tbl$context == "CG", names(cnames.required)]
#		if (nrow(tbl) > 1) {
#			i <- which(tbl[-nrow(tbl), "pos"] + 1L == tbl[-1L, "pos"])
#			if (length(i) != 0) {
#				tbl[i, "C_count"] <- tbl[i, "C_count"] + tbl[i + 1L, "C_count"]
#				tbl[i, "CT_count"] <- tbl[i, "CT_count"] + tbl[i + 1L, "CT_count"]
#				tbl <- tbl[-(i + 1L), ]
#			}
#		}
#		logger.status(c("Retained", nrow(tbl), "record(s) of CpG context in supported chromosomes"))
#		data.frame(
#			"Chromosome" = factor(tbl$chr, levels = SUPPORTED.CHROMOSOMES),
#			"Location" = tbl$pos,
#			"Beta" = tbl$C_count / tbl$CT_count,
#			"Coverage" = tbl$CT_count)
#	}
#)
#names(rrbs.dkfz) <- samples.common
#rm(dir.base, fnames, samples.common)
#
### Combine RRBS DKFZ into a matrix
#positions.all <- unique(do.call(rbind, rrbs.dkfz)[, 1:2])
#positions.all <- positions.all[with(positions.all, order(Chromosome, Location)), ]
#positions.all <- paste0(positions.all$Chromosome, ":", positions.all$Location)
#rrbs.dkfz.meth <- sapply(rrbs.dkfz, function(x) {
#		result <- rep(as.double(NA), length(positions.all))
#		names(result) <- positions.all
#		result[paste0(x$Chromosome, ":", x$Location)] <- x$Beta
#		names(result) <- NULL
#		result
#	}
#)
#rrbs.dkfz.covg <- sapply(rrbs.dkfz, function(x) {
#		result <- rep(0L, length(positions.all))
#		names(result) <- positions.all
#		result[paste0(x$Chromosome, ":", x$Location)] <- x$Coverage
#		names(result) <- NULL
#		result
#	}
#)
#locations[["RRBS DKFZ"]] <- positions.all
#meth.data[["RRBS DKFZ"]] <- rrbs.dkfz.meth
#coverages[["RRBS DKFZ"]] <- rrbs.dkfz.covg
#logger.status("Saved all methylation values to a matrix")
#logger.completed()
#rm(SUPPORTED.CHROMOSOMES, rrbs.dkfz, positions.all, rrbs.dkfz.meth, rrbs.dkfz.covg)
#
## Construct sets with minimal coverage 10
logger.start("Coverage Tresholds")
coverage.limit <- 5L
for (dname in names(coverages)) {
	mm <- meth.data[[dname]]
	mm[coverages[[dname]] < coverage.limit] <- NA
	i <- which(!apply(is.na(mm), 1, all))
	if (length(i) == 0) {
		logger.warning(c("Cannot apply coverage threshold of", coverage.limit, "to", dname))
		next
	}
	dname.new <- paste(dname, coverage.limit)
	locations[[dname.new]] <- locations[[dname]][i]
	meth.data[[dname.new]] <- mm[i, , drop = FALSE]
	coverages[[dname.new]] <- coverages[[dname]][i, , drop = FALSE]
	logger.status(c("Appled coverage threshold of", coverage.limit, "to", dname))
}
logger.completed()
rm(coverage.limit, dname, mm, i, dname.new)

## Save the resulting objects to a file
fname <- file.path(DIR.DATASETS, "comparison.data.RData")
save(locations, meth.data, coverages, file = fname, compression_level = 9L)
logger.status(c("Saved all results to", fname))

logger.completed()


}