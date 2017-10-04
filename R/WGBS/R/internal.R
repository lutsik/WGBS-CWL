########################################################################################################################
## internal.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Functions related to assembly CpGs generation. These functions are never exported or used within the package.
########################################################################################################################

########################################################################################################################

#' Initialize an assembly
#'
#' Initializes an assembly by saving genomic coordinates of CpG and filling in an annotation table.
#'
#' @param assembly.name  Assembly name as a one-element \code{character} vector.
#' @param dir.assemblies Base directory to store assemblies.
#' @return Invisibly, the initialized assembly as an instance of \code{\linkS4class{AssemblyCpGs}}.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.initialize.assembly <- function(assembly.name, dir.assemblies) {
	suppressPackageStartupMessages(library(GenomicRanges))
	pname <- paste0("RnBeads.", assembly.name)
	if (!suppressWarnings(require(pname, quietly = TRUE, character.only = TRUE))) {
		stop(paste("Missing required package", pname))
	}
	load(system.file(paste0("data/", assembly.name, ".RData"), package = pname))
	chromosome.names <- get(assembly.name)$CHROMOSOMES
	chromosome2index <- 1:length(chromosome.names)
	names(chromosome2index) <- chromosome.names
	load(system.file("data/CpG.RData", package = paste0("RnBeads.", assembly.name))) # -> sites
	sites <- endoapply(sites$sites, function(x) { x[seq(1L, length(x) - 1L, by = 2L)] })
	chromosome2index <- chromosome2index[names(chromosome.names) %in% names(sites)]
	chromosome.names <- chromosome.names[names(chromosome.names) %in% names(sites)]

	## Clear the directory if existing
	dir.assembly <- file.path(dir.assemblies, assembly.name)
	if (file.exists(dir.assembly)) {
		if (unlink(dir.assembly, TRUE, TRUE) != 0) {
			stop(paste("Could not remove existing file or directory:", dir.assembly))
		}
	}
	if (!dir.create(dir.assembly, FALSE, TRUE)) {
		stop(paste("Could not create directory:", dir.assembly))
	}

	## Save CpG coordinates
	site.coordinates <- lapply(sites, start)
	site.coordinates <- unlist(site.coordinates, use.names = FALSE)
	wgbs.save.coordinates(site.coordinates, file.path(dir.assembly, "001.WGBS"))
	rm(site.coordinates)

	## Save chromosome annotation
	site.chroms <- unname(sapply(sites, length))
	annotations <- data.frame(
		"V1" = factor(rep("chromosome", length(chromosome.names)), levels = c("chromosome", "CpG island relation")),
		"V2" = unname(chromosome.names),
		"V3" = site.chroms, stringsAsFactors = FALSE)
	rm(site.chroms)

	## Save CGI relation annotation
	site.cgis <- lapply(sites, function(x) { as.integer(mcols(x)[, "CGI Relation"]) })
	site.cgis <- unlist(site.cgis, use.names = FALSE)
	wgbs.save.rds(site.cgis, file.path(dir.assembly, "002.WGBS"))
	annotations <- rbind(annotations, data.frame(
		"V1" = factor(rep("CpG island relation"), levels = levels(annotations[, 1])),
		"V2" = tolower(levels(mcols(sites[[1]])[, "CGI Relation"])),
		"V3" = tabulate(site.cgis), stringsAsFactors = FALSE))
	colnames(annotations) <- colnames(EMPTY.ANNOTATIONS)
	rm(site.cgis)

	## Save annotations table
	attr(annotations, "name") <- assembly.name
	wgbs.save.rds(annotations, file.path(dir.assembly, "000.WGBS"))

	invisible(methods::new("AssemblyCpGs", dir.assembly, annotations))
}

#WGBS:::wgbs.initialize.assembly("hg19", "/Users/assenov/WGBS/Assemblies")
#WGBS:::wgbs.initialize.assembly("hg38", "/Users/assenov/WGBS/Assemblies")

########################################################################################################################

wgbs.initialize.toy.assembly <- function() {
	## Define all CpGs in the toy example genome
	cpgs <- data.frame(
		"Chr" = c("1", "1", "1", "1", "1", "1", "2", "2", "X", "X", "X"),
		"Pos" = c( 2L,  4L, 12L, 19L, 21L, 25L,  4L,  9L,  1L,  4L, 10L),
		"CGI" = c("I", "I", "O", "I", "I", "S", "O", "O", "E", "I", "O"),
		stringsAsFactors = FALSE)
	cpgs[, 1] <- factor(cpgs[, 1], levels = unique(cpgs[, 1]))
	cpgs[, 3] <- factor(cpgs[, 3], levels = c("O", "E", "S", "I"))
	levels(cpgs[, 3]) <- c("open sea", "shelf", "shore", "island")

	## Construct an annotation table
	annotations <- data.frame(
		"V1" = rep(c("chromosome", "CpG island relation"), c(nlevels(cpgs[, 1]), nlevels(cpgs[, 3]))),
		"V2" = c(levels(cpgs[, 1]), levels(cpgs[, 3])),
		"V3" = c(as.integer(table(cpgs[, 1])), as.integer(table(cpgs[, 3]))), stringsAsFactors = FALSE)
	annotations[, 1] <- factor(annotations[, 1], levels = unique(annotations[, 1]))
	colnames(annotations) <- colnames(EMPTY.ANNOTATIONS)
	attr(annotations, "name") <- "Toy assembly"

	## Save annotation table, coordinates and all annotations listed in the table
	TOY.ASSEMBLY <- list(annotations, cpgs[, 2], as.integer(cpgs[, 3]))
	save(TOY.ASSEMBLY, file = "R/sysdata.rda", compression_level = 9L)
}

#WGBS:::wgbs.initialize.toy.assembly()
