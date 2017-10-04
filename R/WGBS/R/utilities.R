########################################################################################################################
## utilities.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Utility functions and global variables used in the WGBS package.
########################################################################################################################

## G E N E R A L #######################################################################################################

wgbs.null <- function(e) { NULL }

## M E T R I C S #######################################################################################################

wgbs.strand.specific.to.cpgs <- function(x) {
	if (is.null(x)) {
		return(NULL)
	}
	ii <- seq(1L, length(x), by = 2L)
	if (is.logical(x)) {
		return(x[ii] | x[ii + 1L])
	}
	return(x[ii] + x[ii + 1L])
}

########################################################################################################################

wgbs.get.indices <- function(bcalls1, bcalls2, operation, strand.specific, acceptable, ind.acceptable) {

	result <- lapply(names(bcalls1@chromosomes), wgbs.null)
	for (i in 1:length(result)) {
		suppressWarnings(rm(flags.acc, flags.all, flags, k))

		## Extract CpGs within the annotation of interest
		if (!is.null(acceptable)) {
			flags.acc <- rep(acceptable[(ind.acceptable[i] + 1):ind.acceptable[i + 1]], each = 2)
			if (!any(flags.acc)) {
				next
			}
		}

		## Load targeted CpGs by the pipelines
		flags.all <- list(NULL, NULL)
		if (bcalls1@chromosomes[i] != 0L) {
			flags.all[[1]] <- wgbs.load.chrom.results(bcalls1, i, "F")
		} else if (operation == "intersection") {
			next
		}
		if (bcalls2@chromosomes[i] != 0L) {
			flags.all[[2]] <- wgbs.load.chrom.results(bcalls2, i, "F")
		} else if (operation == "intersection" || is.null(flags.all[[1]])) {
			next
		}

		## Compute intersection or union of CpGs
		if (strand.specific) {
			flags.cpg <- flags.all
		} else {
			flags.cpg <- lapply(flags.all, wgbs.strand.specific.to.cpgs)
		}
		if (operation == "intersection") {
			flags <- flags.cpg[[1]] & flags.cpg[[2]]
		} else { # operation == "union"
			if (is.null(flags.cpg[[1]])) {
				flags <- flags.cpg[[2]]
			} else if (is.null(flags.cpg[[2]])) {
				flags <- flags.cpg[[1]]
			} else {
				flags <- flags.cpg[[1]] | flags.cpg[[2]]
			}
		}
		if (!strand.specific) {
			flags <- rep(flags, each = 2L)
		}
		rm(flags.cpg)
		if (!is.null(acceptable)) {
			flags <- flags & flags.acc
		}
		k <- which(flags)
		if (length(k) == 0) {
			next
		}

		## Construct the resulting matrix
		xx <- matrix(0L, nrow = length(k), ncol = 3)
		xx[, 1] <- k
		if (strand.specific && operation == "intersection") {
			xx[, 2] <- which(flags[flags.all[[1]]])
			xx[, 3] <- which(flags[flags.all[[2]]])
		} else {
			for (j in 1:2) {
				if (!is.null(flags.all[[j]])) {
					yy <- cumsum(flags.all[[j]])
					yy[!flags.all[[j]]] <- 0L
					xx[, j + 1] <- yy[flags]
				}
			}
		}
		result[[i]] <- xx
		suppressWarnings(rm(xx, j, yy))
	}

	return(result)
}

########################################################################################################################

wgbs.get.value.count <- function(indices, strand) {
	if (is.null(indices)) {
		return(0L)
	}
	if (strand == "*") {
		return(nrow(indices) %/% 2L)
	}
	return(sum(indices[, 1] %% 2L == as.integer(strand == "+")))
}

########################################################################################################################

wgbs.get.values <- function(bcalls1, bcalls2, i.elements, strand) {

	## Initialize the resulting structure
	N.elements <- sapply(i.elements, wgbs.get.value.count, strand = strand)
	N <- sum(N.elements)
	result <- list(
		"m" = list(rep(0L, N), rep(0L, N)),
		"u" = list(rep(0L, N), rep(0L, N)),
		"beta" = list())

	## Extract number of methylated and unmethylated reads
	N.filled <- 0L
	for (i.chromosome in 1:length(i.elements)) {
		if (N.elements[i.chromosome] == 0) {
			next
		}
		indices <- i.elements[[i.chromosome]]
		if (strand != "*") {
			indices <- indices[indices[, 1] %% 2L == as.integer(strand == "+"), , drop = FALSE]
		}
		i2fill <- (N.filled + 1L):(N.filled + N.elements[i.chromosome])
		for (i.pipeline in 1:2) {
			i <- which(indices[, i.pipeline + 1L] != 0L)
			if (length(i) == 0) {
				next
			}
			if (i.pipeline == 1L) { bcalls <- bcalls1 } else { bcalls <- bcalls2 }
			x <- wgbs.load.chrom.results(bcalls, i.chromosome, "R")
			if (length(i) == nrow(indices)) {
				ii <- indices[, i.pipeline + 1L]
				xm <- x[2L * ii - 1L]
				xu <- x[2L * ii]
			} else {
				ii <- indices[i, i.pipeline + 1L]
				xm <- rep(0L, nrow(indices))
				xu <- rep(0L, nrow(indices))
				xm[i] <- x[2L * ii - 1L]
				xu[i] <- x[2L * ii]
			}
			if (strand == "*") {
				xm <- wgbs.strand.specific.to.cpgs(xm)
				xu <- wgbs.strand.specific.to.cpgs(xu)
			}
			result[["m"]][[i.pipeline]][i2fill] <- xm
			result[["u"]][[i.pipeline]][i2fill] <- xu
		}
		suppressWarnings(rm(indices, i2fill, i.pipeline, i, x, ii, xm, xu))

		N.filled <- N.filled + N.elements[i.chromosome]
	}
	rm(N.elements, N, N.filled, i.chromosome)

	## Compute methylation beta values
	for (i in 1:2) {
		result[["beta"]][[i]] <- result[["m"]][[i]] / (result[["m"]][[i]] + result[["u"]][[i]])
	}
	result
}

########################################################################################################################

#' Compute agreement histogram
#'
#' Calculates agreements between two beta vectors and constructs a 2D histogram of frequencies.
#'
#' @param xx        First vector of methylation beta values.
#' @param yy        Second vector of methylation beta values. This must be of the same length as \code{xx}.
#' @param bin.count Number of bins to split the interval [0, 1] to.
#' @return Table for plotting the 2D histogram in the form of a \code{data.frame} with the following columns:
#'         \code{"xmin"}, \code{"xmax"}, \code{"ymin"}, \code{"ymax"} and \code{"fill"}.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.calculate.agreement.bins <- function(xx, yy, bin.count = 51L) {
	if (length(xx) == 0) {
		return(data.frame(
			xmin = double(),
			xmax = double(),
			ymin = double(),
			ymax = double(),
			fill = double()))
	}
	tobin <- function(x) {
		result <- floor(x / (1 / bin.count)) + 1L
		result[result > bin.count] <- bin.count
		result
	}
	dd <- tapply(1:length(xx), list(Y = tobin(yy), X = tobin(xx)), length)
	if (nrow(dd) != bin.count || ncol(dd) != bin.count) {
		dd.orig <- dd
		dd <- matrix(NA_integer_, nrow = bin.count, ncol = bin.count)
		rownames(dd) <- colnames(dd) <- 1:bin.count
		for (i in rownames(dd.orig)) {
			for (j in colnames(dd.orig)) {
				dd[i, j] <- dd.orig[i, j]
			}
		}
		rm(dd.orig, i, j)
	}
	bins <- seq(0, 1, length = bin.count + 1L)
	dframe <- data.frame(
		xmin = rep(bins[-(bin.count + 1L)], each = bin.count),
		xmax = rep(bins[-1], each = bin.count),
		ymin = rep(bins[-(bin.count + 1L)], bin.count),
		ymax = rep(bins[-1], bin.count),
		fill = log10(as.vector(dd)))
	dframe[!is.na(dframe$fill), ]
}

########################################################################################################################

#' Plot agreement histogram
#'
#' Creates a 2D histogram of frequencies of methylation beta values.
#'
#' @param dframe    Agreement bins as computed by \code{\link{wgbs.calculate.agreement.bins}}.
#' @param xlabel    Name of the first pipeline; this is used to label the \code{x} axis.
#' @param ylabel    Name of the second pipeline; this is used to label the \code{y} axis.
#' @param swap.axes Flag indicating if the data in \code{dframe} on the x and y axes should be swapped.
#' @return 2D histogram in the form of a \code{ggplot} instance.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.plot.agreement.bins <- function(dframe, xlabel, ylabel, swap.axes = FALSE) {
	if (swap.axes) {
		pp <- list(xmin = "xmin", xmax = "xmax", ymin = "ymin", ymax = "ymax", fill = "fill")
	} else {
		pp <- list(xmin = "ymin", xmax = "ymax", ymin = "xmin", ymax = "xmax", fill = "fill")
	}
	ggplot(dframe, do.call(aes_string, pp)) + coord_fixed() +
		geom_rect() + labs(x = xlabel, y = ylabel, fill = "Sites\n(logarithmized)") +
		scale_fill_gradient(low = "#FFFFFF", high = "#000000", na.value = "#FFFFFF") +
		geom_abline(slope = 1, intercept = 0, color = "red") +
		scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, length.out = 11), expand = c(0, 0)) +
		scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, length.out = 11), expand = c(0, 0)) +
		theme(panel.background = element_blank(), panel.grid = element_blank())
}

########################################################################################################################

#' Parse available metrics
#'
#' Loads the metric definition table for a TAB-separated text file.
#'
#' @param fname Name of the file storing the metric defintion table as TAB-separated text format.
#' @return A metric definition table as a \code{data.frame} with the following columns: \code{"Name"},
#'         \code{"Single strand"}, \code{"Both strands"}, \code{"Sites"}, \code{"Symmetric"} and \code{"Function"}.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.parse.metrics <- function(fname = system.file("extdata/metrics.txt", package = "WGBS")) {
	empty.dframe <- data.frame(
		"Name" = character(),
		"Type" = factor(character(), levels = c("integer", "numeric")),
		"Single strand" = logical(),
		"Both strands" = logical(),
		"Sites" = factor(character(), levels = c("intersection", "union")),
		"Symmetric" = logical(),
		"Function" = character(), check.names = FALSE, stringsAsFactors = FALSE)
	result <- list(file = fname, quote = "", na.strings = "", check.names = FALSE, stringsAsFactors = FALSE)
	result <- tryCatch(do.call(read.delim, result), error = wgbs.null)
	if (is.null(result)) {
		warning(paste("Missing or invalid file", fname))
		return(empty.dframe)
	}
	if (!identical(colnames(result), colnames(empty.dframe))) {
		warning(paste("Invalid file", fname))
		return(empty.dframe)
	}
	if (any(sapply(result, function(x) { any(is.na(x)) }))) {
		warning(paste("Missing values in file", fname))
		return(empty.dframe)
	}
	for (i in 1:ncol(result)) {
		x <- as.character(result[, i])
		if (is.character(empty.dframe[, i])) {
			result[, i] <- x
		} else if (is.logical(empty.dframe[, i])) {
			if (!all(x %in% c("yes", "no"))) {
				warning(paste("Invalid values in column", colnames(result)[i]))
				return(empty.dframe)
			}
			result[, i] <- (x == "yes")
		} else if (is.factor(empty.dframe[, i])) {
			if (!all(x %in% levels(empty.dframe[, i]))) {
				warning(paste("Invalid values in column", colnames(result)[i]))
				return(empty.dframe)
			}
			result[, i] <- factor(x, levels = levels(empty.dframe[, i]))
		} else { # is.integer(empty.dframe[, i]) || is.numeric(empty.dframe[, i])
			x <- suppressWarnings(do.call(paste0('as.', class(empty.dframe[, i])), list(x = x)))
			if (any(is.na(x))) {
				warning(paste("Invalid values in column", colnames(result)[i]))
				return(empty.dframe)
			}
			result[, i] <- x
		}
	}
	result[order(as.integer(result$Sites)), ]
}

## G L O B A L S #######################################################################################################

## Metrics definition table; loaded from extdata/metrics.txt
WGBS.REGISTERED.METRICS <- wgbs.parse.metrics()
