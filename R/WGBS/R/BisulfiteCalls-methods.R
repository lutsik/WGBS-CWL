########################################################################################################################
## BisulfiteCalls-methods.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Methods accessing the data stored in an BisulfiteCalls class.
########################################################################################################################

## G L O B A L S #######################################################################################################

EMPTY.BISULFITE.CALLS <- list(
	"beta" = double(),
	"coverage" = integer(),
	"mC" = integer(),
	"C" = integer(),
	"reads" = matrix(0L, nrow = 2L, ncol = 0L))

## M E T H O D S #######################################################################################################

setMethod(
	"initialize",
	"BisulfiteCalls",
	function(.Object, dir.calls, title, assembly, chromosomes) {
		.Object@dir.calls <- normalizePath(dir.calls, "/", FALSE)
		.Object@title <- title
		.Object@assembly <- assembly
		.Object@chromosomes <- chromosomes
		.Object
	}
)

########################################################################################################################

setMethod(
	"show",
	"BisulfiteCalls",
	function(object) {
		cat("Object of class ", class(object), "\n", sep = "")
		cat("               Title: ", object@title, "\n", sep = "")
		cat("            Assembly: ", object@assembly, "\n", sep = "")
		cat("            Location: ", object@dir.calls, "\n", sep = "")
		cat(" Covered chromosomes: ", sum(object@chromosomes != 0), "\n", sep = "")
		cat("        Covered CpGs: ", sum(object@chromosomes), "\n", sep = "")
	}
)

########################################################################################################################

if (!isGeneric("wgbs.assembly")) setGeneric('wgbs.assembly', function(object, ...) standardGeneric('wgbs.assembly'))

#' @rdname wgbs.assembly-methods
#' @export
setMethod(
	"wgbs.assembly",
	signature(object = "BisulfiteCalls"),
	function(object) { object@assembly }
)

########################################################################################################################
########################################################################################################################

#' Load pipeline results
#'
#' Loads previously saved instance of \code{BisulfiteCalls}.
#'
#' @param dir.calls Directory in which the pipeline results are saved.
#' @return The loaded instance of \code{\linkS4class{BisulfiteCalls}}.
#'
#' @author Yassen Assenov
#' @export
wgbs.load.pipeline.results <- function(dir.calls) {
	if (!(is.character(dir.calls) && length(dir.calls) == 1 && isTRUE(dir.calls != ""))) {
		stop("Invalid value for dir.calls")
	}
	if (!isTRUE(file.info(dir.calls)[, "isdir"])) {
		stop("Invalid value for dir.calls; expected an existing directory")
	}
	wgbs.load.bisulfite.calls.meta(dir.calls)
}

########################################################################################################################

#' Get local bisulfite calls
#'
#' Gets the results of a bisulfite pipeline for the given genomic region.
#'
#' @param bcalls      Pipeline results as an object of type \code{\linkS4class{BisulfiteCalls}}.
#' @param chromosome  Name of targeted chromosome. This must be one of the chromosomes supported by the corresponding
#'                    \code{\linkS4class{AssemblyCpGs}} instance.
#' @param range.first First base of the targeted region given as 1-based genomic position.
#' @param range.last  First base of the targeted region given as 1-based genomic position.
#' @param dtype       Requested data type, specified as one of: \code{"beta"} (methylation value), \code{"coverage"}
#'                    (coverage), \code{"mC"} (number of reads with methylated cytosine), \code{"C"} (number of reads
#'                    with unmethylated cytosine) or \code{"reads"} (both \code{mC} and \code{C}).
#' @return ...
#'
#' @author Yassen Assenov
#' @export
wgbs.get.bisulfite.calls <- function(bcalls, chromosome, range.first, range.last, dtype = "beta") {
	## Validate parameters
	if (!inherits(bcalls, "BisulfiteCalls")) {
		stop("Invalid value for bcalls")
	}
	if (!(is.character(chromosome) && length(chromosome) == 1 && isTRUE(chromosome != ""))) {
		stop("Invalid value for chromosome")
	}
	i.chromosome <- which(names(bcalls@chromosomes) == chromosome)
	if (length(i.chromosome) == 0) {
		stop("Unsupported chromosome")
	}
	if (is.double(range.first) && isTRUE(all(range.first == as.integer(range.first)))) {
		range.first <- as.integer(range.first)
	}
	if (!(is.integer(range.first) && length(range.first) == 1 && isTRUE(range.first > 0L))) {
		stop("Invalid value for range.first")
	}
	if (is.double(range.last) && isTRUE(all(range.last == as.integer(range.last)))) {
		range.last <- as.integer(range.last)
	}
	if (!(is.integer(range.last) && length(range.last) == 1 && isTRUE(range.last > 0L))) {
		stop("Invalid value for range.last")
	}
	if (range.last < range.first) {
		stop("Invalid value for range.last; expected not smaller than range.first")
	}
	if (!(is.character(dtype) && length(dtype) == 1 && isTRUE(dtype %in% names(EMPTY.BISULFITE.CALLS)))) {
		txt <- paste(names(EMPTY.BISULFITE.CALLS), collapse = ", ")
		stop(paste("Invalid value for dtype; expected one of", txt))
	}

	## Extract all CpGs with measurements
	if (bcalls@chromosomes[i.chromosome] == 0L) {
		return(EMPTY.BISULFITE.CALLS[[dtype]])
	}
	genome.assembly <- wgbs.get.assembly(bcalls@assembly)
	con.coordinates <- tryCatch(
		suppressWarnings(file(file.path(genome.assembly@dir.assembly, "001.WGBS"), "rb")),
		error = wgbs.null)
	chrom.sizes <- unname(wgbs.get.chrom.cpgs(genome.assembly))
	if (i.chromosome == 1) {
		offset <- 0L
	} else {
		offset <- sum(chrom.sizes[1:(i.chromosome - 1)])
	}
	cpg.coords <- wgbs.load.coordinates(con.coordinates, chrom.sizes[i.chromosome], offset)
	cpg.coords <- rep(cpg.coords, each = 2) + 0:1
	close(con.coordinates)
	rm(con.coordinates, chrom.sizes, offset)

	## Construct the result
	if (range.first > tail(cpg.coords, 1) || range.last < cpg.coords[1]) {
		return(EMPTY.BISULFITE.CALLS[[dtype]])
	}
	ii <- findInterval(c(range.first, range.last), cpg.coords, all.inside = TRUE)
	if (cpg.coords[ii[1]] < range.first) {
		if (ii[1] == ii[2]) {
			return(EMPTY.BISULFITE.CALLS[[dtype]])
		}
		ii[1] <- ii[1] + 1L
	}
	ii <- ii[1]:ii[2]
	flags <- wgbs.load.chrom.results(bcalls, i.chromosome, "F")
	N <- sum(flags[ii])
	if (N == 0) {
		return(EMPTY.BISULFITE.CALLS[[dtype]])
	}
	reads <- wgbs.load.chrom.results(bcalls, i.chromosome, "R")
	if (ii[1] == 1) {
		cpg.first <- 1L
	} else {
		cpg.first <- sum(head(flags, ii[1] - 1)) * 2L + 1L
	}
	reads <- reads[cpg.first:(cpg.first + 2 * N - 1)]
	result <- matrix(reads, nrow = 2L, ncol = N)
	if (dtype == names(EMPTY.BISULFITE.CALLS)[1]) {
		result <- result[1, ] / (result[1, ] + result[2, ])
	} else if (dtype == names(EMPTY.BISULFITE.CALLS)[2]) {
		result <- result[1, ] + result[2, ]
	} else if (dtype == names(EMPTY.BISULFITE.CALLS)[3]) {
		result <- result[1, ]
	} else if (dtype == names(EMPTY.BISULFITE.CALLS)[4]) {
		result <- result[2, ]
	}
	attr(result, "annotation") <- data.frame(
		"Location" = cpg.coords[ii],
		"Strand" = factor(ifelse(ii %% 2L == 1L, "+", "-"), levels = c("+", "-")))
	result
}

########################################################################################################################

#' Save meta data of BisulfiteCalls
#'
#' Saves the meta data of pipeline results.
#'
#' @param object Pipeline results in the form of a \code{\linkS4class{BisulfiteCalls}} instance.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.save.bisulfite.calls.meta <- function(object) {
	fname <- file.path(object@dir.calls, "000.RDS")
	wgbs.save.rds(list("title" = object@title, "assembly" = object@assembly, "chromosomes" = object@chromosomes), fname)
}

########################################################################################################################

#' Load meta data of BisulfiteCalls
#'
#' Loads the meta data of saved pipeline results and initializes a \code{BisulfiteCalls} object.
#'
#' @param dir.calls Directory to which pipeline results were stored.
#' @return The newly initialized \code{\linkS4class{BisulfiteCalls}} instance.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.load.bisulfite.calls.meta <- function(dir.calls) {
	meta.data <- tryCatch(suppressWarnings(readRDS(file.path(dir.calls, "000.RDS"))), error = wgbs.null)
	expected.types <- c("title" = "character", "assembly" = "character", "chromosomes" = "integer")
	if (!(is.list(meta.data) && identical(sapply(meta.data, class), expected.types))) {
		stop("Missing or invalid meta data file")
	}
	meta.data <- c(list("BisulfiteCalls", "dir.calls" = dir.calls), meta.data)
	result <- tryCatch(suppressWarnings(do.call(methods::new, meta.data)), error = wgbs.null)
	if (is.null(result)) {
		stop("Missing or invalid meta data file")
	}
	result
}

########################################################################################################################

#' Save results for a chromosome
#'
#' Saves the reuslts of a pipeline for the given chromosome.
#'
#' @param bcalls       Object of type \code{\linkS4class{BisulfiteCalls}} to be modified.
#' @param i.chromosome Chromosome index to be operated on.
#' @param i.indices    Non-empty vector of positive \code{integer} indices, in which odd numbers denote the forward
#'                     strand, and even numbers - the reverse strand.
#' @param flags        Vector of flags denoting the indices of CpGs on the chromosome for which measurements are
#'                     available. Odd numbers denote the forward strand, and even numbers - the reverse strand.
#' @param x            Vector of observed reads per cytosine. This must be an \code{integer} vector of length
#'                     \code{2 * length(i.indices)}, specifying mC and C.
#' @return The modified object \code{bcalls}.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.save.chrom.results <- function(bcalls, i.chromosome, flags, x) {
	fnames <- sprintf("%s/%s%03d.RDS", bcalls@dir.calls, c("F", "R"), i.chromosome)
	wgbs.save.rds(flags, fnames[1])
	wgbs.save.rds(x, fnames[2])
	bcalls@chromosomes[i.chromosome] <- sum(flags)
	bcalls
}

########################################################################################################################

#' Load results for a chromosome
#'
#' Loads the reuslts of a pipeline for the given chromosome.
#'
#' @param bcalls       Object of type \code{\linkS4class{BisulfiteCalls}} to be modified.
#' @param i.chromosome Chromosome index to be operated on.
#' @param dtype        One of \code{"F"} (flags) or \code{"R"} (reads), denoting the data type to retrieve.
#' @return ...
#'
#' @author Yassen Assenov
#' @noRd
wgbs.load.chrom.results <- function(bcalls, i.chromosome, dtype = "F") {
	fname <- sprintf("%s/%s%03d.RDS", bcalls@dir.calls, dtype, i.chromosome)
	if (!file.exists(fname)) {
		stop(paste("Internal error: Missing required file", fname))
	}
	result <- tryCatch(readRDS(fname), error = function(err) { NULL })
	if (is.null(result)) {
		stop(paste("Internal error: Cannot load data from file", fname))
	}
	result
}
