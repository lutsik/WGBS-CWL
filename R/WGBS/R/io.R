########################################################################################################################
## io.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Loading/saving data structers used in the WGBS classes from/to files.
########################################################################################################################

## F U N C T I O N S ###################################################################################################

#' Import results from a pipeline
#'
#' Loads the methylation calls from a TAB-separated text file.
#'
#' @param fname           File containing the methylation calls in \code{bismarkCytosine} format.
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @param dir.result      Directory to contain the converted results of the bisulfite sequencing pipeline. This must be
#'                        a non-existing path, as this function tries to create it.
#' @param title           Title of the pipeline, to be using in plotting.
#' @param verbose         Flag indicating if the function should print messages during the processes of loading and
#'                        conversion.
#' @return Loaded methylation calls as an instance of \code{\linkS4class{BisulfiteCalls}}.
#'
#' @details The input file should be a TAB-separated text file with the following columns:
#' \describe{
#'   \item{Chromosome}{Chromosome name as used in Ensembl or UCSC.}
#'   \item{Location}{The first position of the CpG dinucleotide as a zero-based coordinate.}
#'   \item{Strand}{Strand to be considered.}
#'   \item{mC}{Number of observed reads with methylated cytosine.}
#'   \item{C}{Number of observed reads with unmethylated cytosine.}
#' }
#' Any other columns after the 5th one, if present, are ignored.
#'
#' @author Yassen Assenov
#' @export
wgbs.import.pipeline.results <- function(fname, genome.assembly, dir.result, title = basename(fname), verbose = TRUE) {
	## Validate parameter values
	if (!(is.character(fname) && length(fname) == 1 && isTRUE(fname != ""))) {
		stop("Invalid value for fname")
	}
	if (!file.exists(fname)) {
		stop(paste("File does not exist:", fname))
	}
	if (!inherits(genome.assembly, "AssemblyCpGs")) {
		genome.assembly <- wgbs.get.assembly(genome.assembly)
	}
	if (!(is.character(dir.result) && length(dir.result) == 1 && isTRUE(dir.result != ""))) {
		stop("Invalid value for dir.result")
	}
	if (file.exists(dir.result)) {
		stop("Invalid value for dir.result; expected non-existent path")
	}
	if (!(is.character(title) && length(title) == 1 && isTRUE(title != ""))) {
		stop("Invalid value for title")
	}
	if (!(is.logical(verbose) && length(verbose) == 1 && (!is.na(verbose)))) {
		stop("Invalid value for verbose")
	}

	## Load table of all positions and reads
	tbl <- tryCatch(
		suppressWarnings(utils::read.delim(fname, FALSE, quote = "", na.strings = "")), error = wgbs.null)
	if (is.null(tbl)) {
		stop(paste("Could not load data from:", fname))
	}

	## Validate table structure
	if (ncol(tbl) > 5L) {
		tbl <- tbl[, 1:5]
	} else if (ncol(tbl) != 5L) {
		stop("Invalid file format; expected at least 5 columns")
	}
	chromosomes.all <- wgbs.get.chromosomes(genome.assembly)
	if (is.factor(tbl[, 1])) {
		chromosomes.present <- levels(tbl[, 1]) <- gsub("^chr", "", levels(tbl[, 1]))
		x <- rep(NA_integer_, nrow(tbl))
		for (i in 1:length(chromosomes.all)) {
			j <- which(chromosomes.present == chromosomes.all[i])
			if (length(j) != 0) {
				x[tbl[, 1] == chromosomes.present[j]] <- i
			}
		}
		tbl[, 1] <- factor(x, levels = 1:length(chromosomes.all))
		levels(tbl[, 1]) <- chromosomes.all
		rm(chromosomes.present, x, i, j)
	} else {
		tbl[, 1] <- factor(gsub("^chr", "", tbl[, 1]), levels = chromosomes.all)
	}
	if (!(is.integer(tbl[, 2]) && isTRUE(all(tbl[, 2] >= 0L)))) {
		stop("Invalid file format; column 2 must store chromosome positions")
	}
	tbl[, 2] <- tbl[, 2] + 1L
	if (!(is.factor(tbl[, 3]) && all(levels(tbl[, 3]) %in% c("+", "-")))) {
		stop("Invalid file format; column 3 must store strand (+ or -)")
	}
	x <- rep(0L, nrow(tbl))
	if ("+" %in% levels(tbl[, 3])) {
		x[tbl[, 3] == "+"] <- 1L
	}
	tbl[, 3] <- x
	if (!(is.integer(tbl[, 4]) && isTRUE(all(tbl[, 4] >= 0L)))) {
		stop("Invalid file format; column 4 must store number of mC reads")
	}
	if (!(is.integer(tbl[, 5]) && isTRUE(all(tbl[, 5] >= 0L)))) {
		stop("Invalid file format; column 5 must store number of C reads")
	}
	if (verbose) {
		message(paste("Loaded table with", nrow(tbl), "records"))
	}

	## Focus on supported chromosomes
	x <- which(!is.na(tbl[, 1]))
	if (length(x) == 0) {
		break("All records have missing or unsupported chromosome names")
	}
	if (length(x) != nrow(tbl)) {
		tbl <- tbl[x, ]
		if (verbose) {
			message(paste("Focusing on", nrow(tbl), "records on supported chromosomes"))
		}
	}
	rm(x)

	## Create the output directory
	if (!dir.create(dir.result, FALSE, TRUE)) {
		stop(paste("Could not create directory", dir.result))
	}

	## Split per chromosome and process the table
	chrom.sizes <- wgbs.get.chrom.cpgs(genome.assembly)
	con.coordinates <- tryCatch(
		suppressWarnings(file(file.path(genome.assembly@dir.assembly, "001.WGBS"), "rb")),
		error = wgbs.null)
	if (is.null(con.coordinates)) {
		unlink(dir.result, TRUE, TRUE)
		stop("Internal error: Could not open AssemblyCpGs chromosome coordinates")
	}
	skipped <- FALSE
	x <- rep(0L, length(chromosomes.all)); names(x) <- chromosomes.all
	result <- methods::new("BisulfiteCalls", dir.result, title, wgbs.assembly(genome.assembly), x)
	for (i.chromosome in 1:nlevels(tbl[, 1])) {
		chrom.name <- levels(tbl[, 1])[i.chromosome]
		i <- which(tbl[, 1] == chrom.name & (tbl[, 4] != 0 | tbl[, 5] != 0))
		if (length(i) == 0) {
			skipped <- TRUE
			next
		}
		if (skipped) {
			offset <- sum(chrom.sizes[1:(i.chromosome - 1)])
		} else {
			offset <- 0L
		}
		cpg.coords <- wgbs.load.coordinates(con.coordinates, chrom.sizes[i.chromosome], offset)
		cpg.coords <- rep(cpg.coords, each = 2) + 0:1
		skipped <- 0L
		tbl.chrom <- tbl[i, 2:5]
		if (anyDuplicated(tbl.chrom[, 1])) {
			unlink(dir.result, TRUE, TRUE)
			close(con.coordinates)
			stop(paste("Duplicated coordinates on chromosome", chrom.name))
		}
		i.sorting <- order(tbl.chrom[, 1])
		tbl.chrom <- tbl.chrom[i.sorting, ]
		i.indices <- findInterval(tbl.chrom[, 1], cpg.coords)
		j <- which(i.indices == 0 | i.indices > length(cpg.coords))
		if (length(j) != 0) {
			unlink(dir.result, TRUE, TRUE)
			close(con.coordinates)
			j <- paste0(tbl.chrom[j[1], 1], ":", ifelse(tbl.chrom[j[1], 2] == 0, "-", "+"))
			stop(paste0("Unexpected genomic position ", chrom.name, ":", j))
		}
		j <- which(tbl.chrom[, 1] != cpg.coords[i.indices] | (i.indices %% 2 != tbl.chrom[, 2]))
		if (length(j) != 0) {
			unlink(dir.result, TRUE, TRUE)
			close(con.coordinates)
			j <- paste0(tbl.chrom[j[1], 1], ":", ifelse(tbl.chrom[j[1], 2] == 0, "-", "+"))
			stop(paste0("Unexpected genomic position ", chrom.name, ":", j))
		}
		flags <- rep(FALSE, length(cpg.coords))
		flags[i.indices] <- TRUE
		result <- wgbs.save.chrom.results(result, i.chromosome, flags, c(rbind(tbl.chrom[, 3], tbl.chrom[, 4])))
		rm(cpg.coords, tbl.chrom, i.sorting, i.indices, j, flags)
		if (verbose) {
			message(paste("Saved results for chromosome", chrom.name))
		}
	}
	close(con.coordinates)
	rm(con.coordinates, skipped, x, i.chromosome, chrom.name, i)
	wgbs.save.bisulfite.calls.meta(result)
	result
}

########################################################################################################################

#' Save to RDS file
#'
#' Saves the given R object to an RDS file.
#'
#' @param x     Object to be saved.
#' @param fname Name of the file in which \code{x} is to be stored. This should be a \code{.gz} file. If it already
#'              exists, it will be overwritten.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.save.rds <- function(x, fname) {
	con <- gzfile(fname, "wb", compression = 9L)
	saveRDS(x, con)
	close(con)
}

########################################################################################################################

#' Save and load genomic coordinates
#'
#' Transfer of (sorted) vectors of chromosomal positions to and from a binary file.
#'
#' @param x      Positions to be saved, given as an \code{integer} vector.
#' @param fname  A \code{\link{connection}} object or a character string naming a file.
#' @param n      Number of elements to be read. If the file contains less data available, the loading function
#'               exists with an error.
#' @param offset Optionally, a file position (relative to the origin) to start reading from. The offset should be
#'               specified in number of elements. Setting this parameter to \code{0} or a negative value disables
#'               repositioning.
#'
#' @rdname wgbs.save.coordinates
#' @aliases wgbs.load.coordinates
#' @author Yassen Assenov
#' @noRd
wgbs.save.coordinates <- function(x, fname) {
	writeBin(x, fname, 4L, "little")
}

########################################################################################################################

#' @rdname wgbs.save.coordinates
#' @noRd
wgbs.load.coordinates <- function(fname, n, offset = 0L) {
	if (is.character(fname)) {
		con <- file(fname, "rb")
	} else {
		con <- fname
	}
	if (offset > 0) {
		seek(con, offset * 4L)
	}
	result <- readBin(con, "integer", n, 4L, endian = "little")
	if (is.character(fname)) {
		close(con)
	}
	if (length(result) != n) {
		stop(paste("Internal error: failed to read", n, "coordinates from", fname))
	}
	result
}
