########################################################################################################################
## metrics.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Definitions and implementations of metrics that quantify (dis)agreement between the outcomes of two WGBS pipelines.
########################################################################################################################

## F U N C T I O N S ###################################################################################################

wgbs.metric.total.elements <- function(m, u, beta) {
	length(m[[1]])
}

########################################################################################################################

wgbs.metric.beta.correlation <- function(m, u, beta) {
	cor(beta[[1]], beta[[2]])
}

########################################################################################################################

wgbs.metric.coverage.difference <- function(m, u, beta) {
	mean(m[[1]] - m[[2]] + u[[1]] - u[[2]])
}

########################################################################################################################
########################################################################################################################

#' Compute metrics
#'
#' @param bcalls     \code{list} of two or more objects of type \code{\linkS4class{BisulfiteCalls}}, storing pipeline
#'                   results for the same genome assembly.
#' @param dir.output Directory to contain the output files. This must a non-existing path, as this function attempts to
#'                   create it.
#' @param verbose    Flag indicating if the function should regularly print the progress to the console.
#' @return None (invisible \code{NULL}).
#'
#' @author Yassen Assenov
#' @export
wgbs.compute.metrics <- function(bcalls, dir.output, verbose = TRUE) {
	## Validate parameters
	if (!(is.list(bcalls) && length(bcalls) > 1 && all(sapply(bcalls, inherits, what = "BisulfiteCalls")))) {
		stop("Invalid value for bcalls; expected list two or more BisulfiteCalls")
	}
	genome.assembly <- unique(sapply(bcalls, methods::slot, name = "assembly"))
	if (length(genome.assembly) != 1) {
		stop("Inconsistent genome assemblies")
	}
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	if (!(is.character(dir.output) && length(dir.output) == 1 && isTRUE(dir.output != ""))) {
		stop("Invalid value for dir.output")
	}
	if (!(is.logical(verbose) && length(verbose) == 1 && (!is.na(verbose)))) {
		stop("Invalid value for verbose")
	}
	N <- length(bcalls)
	M <- nrow(WGBS.REGISTERED.METRICS)
	if (M == 0) {
		warning("No registered metrics")
		return(invisible(NULL))
	}
	if (file.exists(dir.output)) {
		stop("Invalid value for dir.output; expected a non-existing path")
	}
	if (!dir.create(dir.output, FALSE, TRUE)) {
		stop(paste("Could not create directory", dir.output))
	}

	## Initialize the structures for statistics and computed pairwise metrics
	init.dframe <- function(i) {
		p1.indices <- rep(1:N, each = N)
		p2.indices <- rep(1:N, N)
		if (WGBS.REGISTERED.METRICS[i, "Symmetric"]) {
			j <- which(p1.indices <= p2.indices)
			p1.indices <- p1.indices[j]
			p2.indices <- p2.indices[j]
			rm(j)
		}
		if (WGBS.REGISTERED.METRICS[i, "Single strand"]) {
			strands <- c("+", "-")
		} else {
			strands <- character()
		}
		if (WGBS.REGISTERED.METRICS[i, "Both strands"]) {
			strands <- c(strands, "*")
		}
		data.frame(
			"St" = factor(rep(strands, each = length(p1.indices)), levels = c("+", "-", "*")),
			"P1" = rep(p1.indices, length(strands)),
			"P2" = rep(p2.indices, length(strands)),
			"Va" = do.call(paste0('as.', WGBS.REGISTERED.METRICS[i, "Type"]), list(x = NA)))
	}

	## Create data frames for pairwise plots
	agreements.computed <- array(FALSE, dim = c(N, N, 3L))

	## Set up bars to report progress
	tbl.annotations <- genome.assembly@annotations
	if (verbose) {
		cat(paste0("Annotations: ", nrow(tbl.annotations) + 1, "\n"))
		cat(paste0(paste(rep(".", 2L + N * N * 2L), collapse = ""), "\n"))
	}

	## Compute metrics
	acceptable <- NULL
	ind.acceptable <- c(0L, cumsum(unname(wgbs.get.chrom.cpgs(genome.assembly))))
	for (annotation.index in 0:nrow(tbl.annotations)) {
#annotation.index <- 4L

		## Load vector of acceptable positions as a flag
		if (annotation.index != 0) {
			c.name <- as.character(tbl.annotations[annotation.index, 1])
			if (c.name == "chromosome") {
				acceptable <- rep(FALSE, tail(ind.acceptable, 1))
				ii <- (ind.acceptable[annotation.index] + 1L):ind.acceptable[annotation.index + 1]
				acceptable[ii] <- TRUE
			} else { # c.name != "chromosome"
				ii <- which(tbl.annotations[, 1] == c.name)
				ii <- which(ii == annotation.index)
				acceptable <- (wgbs.get.annotation(genome.assembly, c.name, FALSE) == ii)
			}
			rm(c.name, ii)
			invisible(gc())
		}
		tbls.agreements <- list()
		results <- lapply(1:M, init.dframe)
		if (verbose) { cat("=") }

		## Compute metrics for intersections and unions
		for (operation in levels(WGBS.REGISTERED.METRICS$Sites)) {
			for (i1 in 1:N) {
				for (i2 in 1:N) {
					for (strand in c("+", "-", "*")) {
#operation <- levels(WGBS.REGISTERED.METRICS$Sites)[1]; i1 <- 1L; i2 <- 2L; strand <- "+"
						ii <- WGBS.REGISTERED.METRICS[, ifelse(strand == "*", "Both strands", "Single strand")]
						ii <- which(ii & WGBS.REGISTERED.METRICS[, "Sites"] == operation)
						ii.valid <- !(length(ii) == 0 || i1 > i2 && all(WGBS.REGISTERED.METRICS[ii, "Symmetric"]))
						if (!(i1 < i2 || ii.valid)) {
							next
						}
						if (strand != "-") {
							i.elements <- wgbs.get.indices(bcalls[[i1]], bcalls[[i2]], operation, strand != "*",
														   acceptable, ind.acceptable)
						}
						all.data <- wgbs.get.values(bcalls[[i1]], bcalls[[i2]], i.elements, strand)
						if (i1 < i2) {
							tbl <- wgbs.calculate.agreement.bins(all.data$m[[1]], all.data$m[[2]])
#							tbl <- tryCatch(
#								wgbs.calculate.agreement.bins(all.data$m[[1]], all.data$m[[2]]),
#								error = wgbs.null)
#							if (is.null(tbl)) {
#								cat("\n")
#								cat(paste0("annotation.index: ", annotation.index, "\n"))
#								cat(paste0("       operation: ", operation, "\n"))
#								cat(paste0("              i1: ", i1, "\n"))
#								cat(paste0("              i2: ", i2, "\n"))
#								cat(paste0("          strand: ", strand, "\n"))
#								cat(paste0("      length(m1): ", length(all.data$m[[1]]), "\n"))
#								cat(paste0("      length(m2): ", length(all.data$m[[2]]), "\n"))
#								return(invisible(NULL))
#							}
							tbls.agreements[[paste(i1, i2, strand, sep = ":")]] <- tbl
						}

						if (ii.valid) {
							for (i in ii) {
								tbl <- results[[i]]
								j <- which(tbl$`St` == strand && tbl$`P1` == i1 && tbl$`P2` == i2)
								if (length(j) == 1L) {
									x <- do.call(WGBS.REGISTERED.METRICS[i, "Function"], all.data)
									results[[i]][j, "Va"] <- x
								}
							}
						}
						suppressWarnings(rm(all.data, i, tbl, j, x))
					}
					suppressWarnings(rm(strand, ii, i.elements))
					if (verbose) { cat("=") }
				}
			}
		}

		## Set pipeline titles
		pipeline.titles <- sapply(bcalls, slot, name = "title")
		for (i in 1:length(results)) {
			for (cname in c("P1", "P2")) {
				results[[i]][, cname] <- factor(results[[i]][, cname], levels = 1:N)
				levels(results[[i]][, cname]) <- pipeline.titles
			}
		}
		rm(pipeline.titles, i, cname)

		## Save the results to a file
		fname <- sprintf("%s/M%03d.RData", dir.output, annotation.index)
		save(tbls.agreements, results, file = fname, compression_level = 9L)
		rm(tbls.agreements, results, fname)
		if (verbose) { cat("=\n") }
	}
	result <- list(
		"metrics" = WGBS.REGISTERED.METRICS,
		"annotations" = tbl.annotations,
		"pipelines" = sapply(bcalls, slot, name = "title"))
	con <- gzfile(sprintf("%s/index.RDS", dir.output), "wb", compression = 9L)
	saveRDS(result, con)
	close(con)
	rm(result, con)
}
