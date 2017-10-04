########################################################################################################################
## 10_measurements_comparison_2.R
## created: 2015-01-27
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Compares the measurements of RRBS and Infinium for those samples, for which all technologies were present.
########################################################################################################################

## L I B R A R I E S ###################################################################################################
#if(TRUE){
suppressPackageStartupMessages(library(RnBeads))
theme_set(theme_bw())

## G L O B A L S #######################################################################################################

#DIR.DATASETS <- ifelse(.Platform$OS.type == "windows", "D:/Datasets", "/icgc/dkfzlsdf/analysis/assenov/Data")
#DIR.DATASETS <- paste0(DIR.DATASETS, "/Methylation")
DIR.DATASETS <-'/ngs_share/scratch/pavlo/benchmark/encode_chr22_test/comparison2'

## F U N C T I O N S ###################################################################################################

plot.square.matrix <- function(mm, rdigits = 0L, fill.limits = NULL) {
	params.fill <- list(low = "#832424", mid = "#FFFFFF", high = "#3A3A98")
	if (!is.null(fill.limits)) {
		params.fill$limits <- fill.limits
	}
#	params.aes <- list(x = 'x', y = 'y', fill = 'v')
	dframe <- data.frame(
		x = factor(rep(colnames(mm), each = nrow(mm)), levels = colnames(mm)),
		y = factor(rep(rownames(mm), ncol(mm)), levels = rev(rownames(mm))),
		v = as.vector(mm),
		t = as.character(round(as.vector(mm), digits = rdigits)), stringsAsFactors = FALSE)
	pp <- ggplot(dframe, aes(x = x, y = y, fill = v, label = t)) + labs(x = NULL, y = NULL, fill = NULL) +
		geom_tile(color = "white") + geom_text() + do.call(scale_fill_gradient2, params.fill) +
		scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) +
		theme(axis.ticks = element_blank(), legend.justification = c(0, 0.5), legend.position = c(1, 0.5)) +
		theme(panel.border = element_blank(), plot.margin = grid::unit(0.1 + c(0, 1, 0, 0), "in"))
	pp <- suppressWarnings(ggplot_gtable(ggplot_build(pp)))
	pp$widths[[3]] <- grid::unit(2, "in")
#	pp$heights[[length(pp$heights) - 2L]] <- grid::unit(0.5, "in")
	pp
}

########################################################################################################################

plot.agreement <- function(xx, yy, bin.count = 51L, xlabel = NULL, ylabel = NULL) {
	tobin <- function(x) {
		result <- floor(x / (1 / bin.count)) + 1L
		result[result > bin.count] <- bin.count
		result
	}
	dd <- tapply(1:length(xx), list(Y = tobin(yy), X = tobin(xx)), length)
	bins <- seq(0, 1, length = bin.count + 1L)
	dframe <- data.frame(
		xmin = rep(bins[-(bin.count + 1L)], each = bin.count),
		xmax = rep(bins[-1], each = bin.count),
		ymin = rep(bins[-(bin.count + 1L)], bin.count),
		ymax = rep(bins[-1], bin.count),
		fill = log10(as.vector(dd)))
	dframe <- dframe[!is.na(dframe$fill), ]
#	dframe <- data.frame(x = xx, y = yy)
	ggplot(dframe, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill)) +
#		stat_bin2d(aes(fill = log10(..count..)), bins = bin.count) +
#		stat_density2d(geom = "tile", aes(fill = log10(..count..)), contour = FALSE) +
		geom_rect() + labs(x = xlabel, y = ylabel, fill = "Sites\n(logarithmized)") +
		scale_fill_gradient(low = "#FFFFFF", high = "#000000", na.value = "#FFFFFF") +
		geom_abline(slope = 1, intercept = 0, color = "red") +
		scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, length.out = 11), expand = c(0, 0)) +
		scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, length.out = 11), expand = c(0, 0)) +
		theme(panel.background = element_blank(), panel.grid = element_blank())
}

## M A I N #############################################################################################################

logger.start("Methylation Values Comparions", fname = "10.log")

## Load the methylation data from a file
fname <- file.path(DIR.DATASETS, "comparison.data.RData")
load(fname) # -> locations, meth.data
logger.status(c("Loaded results from", fname))
#rm(fname)

## ---------------------------------------------------------------------------------------------------------------------
## Initialize the report

dir.report <- file.path(DIR.DATASETS, "reports/comparison")
if (file.exists(dir.report)) {
	if (!isTRUE(file.info(dir.report)[, "isdir"])) {
		logger.error("Supplied report directory is a regular file")
	}
} else if (!dir.create(dir.report, showWarnings = FALSE, recursive = TRUE)) {
	logger.error("Could not create report directory")
}
fname <- file.path(dir.report, "comparison.html")
report <- createReport(fname, "Methylation Data Comparison", "Methylation Data Comparison", "Yassen Assenov",
	init.configuration = !file.exists(file.path(dir.report, "configuration")))
logger.status(c("Initialized report", fname))
#rm(dir.report, fname)

## Create an Introduction section
M <- length(meth.data)
N <- ncol(meth.data[[1]])
txt <- c("This report compares the results of several approaches for measuring and normalizing genome-wide ",
	"methylation data on the same sample. The cohort examined here consists of ",
	ifelse(N == 1, "a single sample", paste(N, "samples")), " interrogated using <b>", M, "</b> technologies.")
report <- rnb.add.section(report, "Introduction", txt)
#rm(txt)

## ---------------------------------------------------------------------------------------------------------------------
## Summarize size of the overlaps

commons <- list()
overlapped <- array(0L, dim = c(N, M, M), dimnames = list(colnames(meth.data[[1]]), names(meth.data), names(meth.data)))
for (k in 1:N) {
	commons[[k]] <- list()
	for (i in 1:M) {
		i.ind <- which(!is.na(meth.data[[i]][, k]))
		for (j in i:M) {
			if (j == i) {
				overlapped[k, i, i] <- length(i.ind)
			} else { # j > i
				j.ind <- which(!is.na(meth.data[[j]][, k]))
				commons[[k]][[paste(i, "and", j)]] <- intersect(locations[[i]][i.ind], locations[[j]][j.ind])
				overlapped[k, i, j] <- overlapped[k, j, i] <- length(commons[[k]][[paste(i, "and", j)]])
			}
		}
	}
}
names(commons) <- dimnames(overlapped)[[1]]
fnames <- paste0("overlap_sizes_", 1:N, ".csv")
for (k in 1:N) {
	write.csv(overlapped[k, , ], file = file.path(rnb.get.directory(report, "data", TRUE), fnames[k]))
}
txt <- c('We first show the overlaps among the different technologies in every sample. The results are presented in ',
	'figure below:')
report <- rnb.add.section(report, "Overlaps and Coverages", txt)

## Create heatmaps with the pairwise overlaps
value.types <- c("abs" = "absolute", "rel" = "relative per row")
report.plots <- list()
for (k in 1:N) {
	for (value.type in names(value.types)) {
		if (value.type == "abs") {
			mm <- overlapped[k, , ] / 1000
			fill.limits <- NULL
		} else { # value.type == "rel"
			mm <- 100 * (overlapped[k, , ] / matrix(rep(diag(overlapped[k, , ]), M), nrow = M, ncol = M))
			fill.limits <- c(0, 100)
		}
		fname <- paste("overlaps", k, value.type, sep = "_")
		rplot <- createReportPlot(fname, report, width = 3.2 + M * 2, height = 0.7 + M * 0.5)
		grid.newpage()
		grid.draw(plot.square.matrix(mm, fill.limits = fill.limits))
		report.plots <- c(report.plots, off(rplot))
	}
}
txt <- c("Heatmap showing the pairwise common CpGs given as absolute numbers (in thousands) or percentages of total ",
	"covered CpGs per sample (indicated by the row name).")
setting.names <- list("Sample" = dimnames(overlapped)[[1]], "Values" = value.types)
names(setting.names[[1]]) <- 1:length(setting.names[[1]])
report <- rnb.add.figure(report, txt, report.plots, setting.names)
txt <- c('The values visualized in the first figure are available in comma-separated files, as listed below:')
rnb.add.paragraph(report, txt)
txt <- data.frame(
	"Sample" = dimnames(overlapped)[[1]],
	"File" = paste0('<a href=\"', rnb.get.directory(report, 'data'), '/', fnames, '\">', fnames, '</a>'),
	stringsAsFactors = FALSE)
rnb.add.table(report, txt, row.names = FALSE)
#rm(overlapped, k, i, i.ind, j, j.ind, fnames, txt, value.types, report.plots, value.type, mm, fname, rplot)
#rm(setting.names)

## ---------------------------------------------------------------------------------------------------------------------
## Calculate distances/agreements between the measurements at common CpGs

## Compute agreements
distances <- array(0, dim = c(N, M, M, 4), dimnames = list(colnames(meth.data[[1]]), names(meth.data), names(meth.data),
		c("Euclidean distance", "Manhattan distance", "Mean absolute difference", "Correlation")))
report.plots <- list()
for (k in 1:N) {
	for (i in 1:M) {
		distances[k, i, i, ] <- c(0, 0, 0, 1)
	}
}
for (k in 1:N) {
	for (i in 1:(M - 1)) {
		for (j in (i + 1):M) {
			ind <- commons[[k]][[paste(i, "and", j)]]
			xx <- meth.data[[i]][, k]; names(xx) <- locations[[i]]; xx <- unname(xx[ind])
			yy <- meth.data[[j]][, k]; names(yy) <- locations[[j]]; yy <- unname(yy[ind])
			distances[k, i, j, ] <- distances[k, j, i, ] <-
				c(sqrt(sum((xx - yy)^2)), sum(abs(xx - yy)), mean(abs(xx - yy)), cor(xx, yy))
			fname <- paste0("agreement_", k, "_", i, "x", j)
			rplot <- createReportPlot(fname, report, width = 8.3, height = 7.2)
			pp <- plot.agreement(xx, yy, bin.count=30, xlabel = names(meth.data)[i], ylabel = names(meth.data)[j]) +
				theme(legend.position = c(1, 0.5), legend.justification = c(0, 0.5)) +
				theme(plot.margin = grid::unit(0.1 + c(0, 1.1, 0, 0), "in"))
			print(pp)
			report.plots <- c(report.plots, off(rplot))
		}
	}
}
txt <- c("Here we inspect the differences at individual CpGs when comparing a pair of techniques applied on the same ",
	"sample.")
report <- rnb.add.section(report, "Agreements", txt)
txt <- c("2D histogram of observed agreements/differences between two techniques.")
setting.names <- list("Sample" = names(commons), "Comparison" = names(commons[[1]]))
names(setting.names[[1]]) <- 1:length(setting.names[[1]])
names(setting.names[[2]]) <- gsub(" and ", "x", setting.names[[2]], fixed = TRUE)
report <- rnb.add.figure(report, txt, report.plots, setting.names)
#rm(report.plots, k, i, j, ind, xx, yy, fname, rplot, pp, txt, setting.names)

## Plot the computed values
stats <- matrix("", nrow = N * (dim(distances)[4]), ncol = 3)
stats[, 1] <- rep(dimnames(distances)[[1]], each = dim(distances)[4])
stats[, 2] <- rep(dimnames(distances)[[4]], dim(distances)[1])
colnames(stats) <- c("Sample", "Metric", "File")
report.plots <- list()
for (k in 1:N) {
	for (d in 1:(dim(distances)[4])) {
		fname <- paste("agreements", k, d, sep = "_")
		rplot <- createReportPlot(fname, report, width = 3.2 + M * 2, height = 0.7 + M * 0.5)
		grid.newpage()
		grid.draw(plot.square.matrix(distances[k, , , d], rdigits = ifelse(d < 3, 0L, 3L)))
		report.plots <- c(report.plots, off(rplot))

		fname <- paste0(fname, ".csv")
		tbl <- cbind(data.frame(x = dimnames(distances)[[2]]), distances[k, , , d])
		colnames(tbl)[1] <- dimnames(distances)[[4]][d]
		write.csv(tbl, file = file.path(rnb.get.directory(report, "data", TRUE), fname), row.names = FALSE)
		i <- (k - 1L) * (dim(distances)[4]) + d
		stats[i, 3] <- paste0('<a href="', rnb.get.directory(report, 'data'), '/', fname, '">', fname, '</a>')
	}
}
txt <- c("Values obtained by calculating a metric for difference or agreement of methylation based on different ",
	"techniques.")
setting.names <- list("Sample" = dimnames(distances)[[1]], "Metric" = dimnames(distances)[[4]])
names(setting.names[[1]]) <- 1:N
names(setting.names[[2]]) <- 1:length(setting.names[[2]])
report <- rnb.add.figure(report, txt, report.plots, setting.names)
txt <- c("The exact values visualized above are available in dedicated comma-separated value files, accompanying this ",
	"report:")
rnb.add.paragraph(report, txt)
rnb.add.table(report, stats, row.names = FALSE)
#rm(stats, report.plots, k, d, fname, rplot, tbl, i, txt, setting.names)

## ---------------------------------------------------------------------------------------------------------------------
## Close the report

report <- off(report)
logger.completed()
#}

