########################################################################################################################
## AssemblyCpGs-methods.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Methods accessing the data stored in an AssemblyCpGs class.
########################################################################################################################

## E N V I R O N M E N T S #############################################################################################

## All registered AssemblyCpGs instances
ASSEMBLY.CPGS <- new.env(FALSE)

## M E T H O D S #######################################################################################################

setMethod(
	"initialize",
	"AssemblyCpGs",
	function(.Object, dir.assembly, annotations) {
		.Object@dir.assembly <- normalizePath(dir.assembly, "/", FALSE)
		.Object@annotations <- annotations
		.Object
	}
)

########################################################################################################################

setMethod(
	"show",
	"AssemblyCpGs",
	function(object) {
		cat("Object of class ", class(object), "\n", sep = "")
		tbl <- object@annotations
		cat(sprintf("     Assembly: %s\n", attr(tbl, "name")))
		cat(sprintf("         CpGs: %d\n", sum(tbl[tbl[, 1] == "chromosome", 3])))
		cat(sprintf("  Annotations: %d\n", nlevels(tbl[, 1])))
		xx <- tapply(tbl[, 2], tbl[, 1], function(x) {
			if (length(x) == 1) { return("") }
			paste(" |", paste(x, collapse = "; "))
		})
		for (x in names(xx)) {
			cat("    ", x, xx[x], "\n", sep = "")
		}
	}
)

########################################################################################################################

if (!isGeneric("wgbs.assembly")) setGeneric('wgbs.assembly', function(object, ...) standardGeneric('wgbs.assembly'))

#' Get targeted assembly
#'
#' Gets the targeted genome assembly.
#'
#' @param object Object of type inheriting \code{\linkS4class{AssemblyCpGs}} or \code{\linkS4class{BisulfiteCalls}}.
#' @return Targeted genome assembly as a one-element \code{character} vector.
#'
#' @rdname wgbs.assembly-methods
#' @docType methods
#' @export
#' @aliases wgbs.assembly
#' @aliases wgbs.assembly,AssemblyCpGs-method
#' @aliases wgbs.assembly,BisulfiteCalls-method
setMethod(
	"wgbs.assembly",
	signature(object = "AssemblyCpGs"),
	function(object) { attr(object@annotations, "name") }
)

########################################################################################################################
########################################################################################################################

#' Load an assembly
#'
#' Loads and registers an AssemblyCpG instance.
#'
#' @param path     Directory containing genome assembly CpG annotation tables, as exported by an
#'                 \code{\linkS4class{AssemblyCpGs}} instance.
#' @param register Flag indicating if the assembly is to be registered, so that it can later be accessed by name.
#' @return Invisibly, the loaded instance of \code{\linkS4class{AssemblyCpGs}}.
#'
#' @author Yassen Assenov
#' @export
wgbs.load.assembly <- function(path, register = TRUE) {
	if (!(is.character(path) && length(path) == 1 && isTRUE(path != ""))) {
		stop("Invalid value for path")
	}
	if (!isTRUE(file.info(path)[, "isdir"])) {
		stop("Invalid value for path; expected an existing directory")
	}
	if (!(is.logical(register) && length(register) == 1 && (!is.na(register)))) {
		stop("Invalid value for register")
	}
	annotations <- tryCatch(readRDS(file.path(path, "000.WGBS")), error = wgbs.null)
	if (!is.data.frame(annotations)) {
		stop(paste("Missing or invalid annotations table in", path))
	}
	result <- methods::new("AssemblyCpGs", path, annotations)
	if (register) {
		assign(wgbs.assembly(result), result, ASSEMBLY.CPGS)
	}
	invisible(result)
}

########################################################################################################################

#' Load the toy assembly
#'
#' Loads the toy assembly used in examples
#' @return The loaded assembly.
#'
#' @examples
#' wgbs.load.toy.assembly()
#'
#' @author Yassen Assenov
#' @export
wgbs.load.toy.assembly <- function() {
	result <- get0(attr(TOY.ASSEMBLY[[1]], "name"), ASSEMBLY.CPGS)
	if (is.null(result)) {
		dir.assembly <- normalizePath(tempfile("assembly"), winslash = "/", mustWork = FALSE)
		if (!dir.create(dir.assembly, FALSE, TRUE)) {
			stop("Could not create temporary directory for the toy assembly")
		}
		wgbs.save.coordinates(TOY.ASSEMBLY[[2]], file.path(dir.assembly, "001.WGBS"))
		wgbs.save.rds(TOY.ASSEMBLY[[3]], file.path(dir.assembly, "002.WGBS"))
		result <- methods::new("AssemblyCpGs", dir.assembly, TOY.ASSEMBLY[[1]])
		assign(wgbs.assembly(result), result, ASSEMBLY.CPGS)
	}
	result
}

########################################################################################################################

#' Get assembly
#'
#' Gets the registered \code{AssemblyCpGs} instance for the given genome assembly.
#'
#' @param genome.assembly Name of genome assembly as a one-element \code{character} vector.
#' @return The assembly's CpG annotation object as an instance of \code{\linkS4class{AssemblyCpGs}}.
#'
#' @seealso \code{\link{wgbs.load.assembly}} for loading and registering \code{AssemblyCpGs}
#' @author Yassen Assenov
#' @export
wgbs.get.assembly <- function(genome.assembly) {
	if (inherits(genome.assembly, "AssemblyCpGs")) {
		return(genome.assembly)
	}
	if (inherits(genome.assembly, "BisulfiteCalls")) {
		genome.assembly <- genome.assembly@assembly
	} else if (!(is.character(genome.assembly) && length(genome.assembly) == 1 && isTRUE(genome.assembly != ""))) {
		stop("Invalid value for genome.assembly")
	}
	result <- get0(genome.assembly, envir = ASSEMBLY.CPGS, inherits = FALSE)
	if (is.null(result)) {
		stop(paste("Unsupported genome assembly", genome.assembly))
	}
	result
}

########################################################################################################################

#' Get assembly chromosomes
#'
#' Gets the list of the supported chromosomes for the given genome assembly
#'
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @return List of supported chromosome names as a non-empty \code{character} vector.
#'
#' @author Yassen Assenov
#' @export
wgbs.get.chromosomes <- function(genome.assembly) {
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	genome.assembly@annotations[genome.assembly@annotations[, 1] == "chromosome", 2]
}

########################################################################################################################

#' Get all CpG annotations
#'
#' Gets the available annotations for genomic CpGs.
#'
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @return List of supported chromosome names as a non-empty \code{character} vector.
#'
#' @author Yassen Assenov
#' @export
wgbs.get.annotations <- function(genome.assembly) {
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	c("strand", levels(genome.assembly@annotations[, 1]))
}

########################################################################################################################

#' Get CpG annotation
#'
#' Gets the annotation of CpGs in the given genome assembly
#'
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @param annotation.name One-element \code{character} vector storing the annotation name.
#' @param simplified      Flag indicating if the result should be converted to a meaningful vector.
#' @return If \code{simplified} is \code{TRUE} and the annotation is formed by a single region set: a \code{logical}
#'         \code{vector}.
#'         If \code{simplified} is \code{TRUE} and the annotation is besed on genomic segmentation: a \code{factor}
#'         object.
#'         If \code{simplified} is \code{FALSE}: an \code{integer} \code{vector}.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.get.annotation <- function(genome.assembly, annotation.name, simplified = TRUE) {
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	if (!(is.character(annotation.name) && length(annotation.name) == 1 && isTRUE(annotation.name != ""))) {
		stop("Invalid value for annotation.name")
	}
	if (!(is.logical(simplified) && length(simplified) == 1 && (!is.na(simplified)))) {
		stop("Invalid value for simplified")
	}
	i <- which(levels(genome.assembly@annotations[, 1]) == annotation.name)
	if (length(i) == 0) {
		stop(paste("Unsupported annotation", annotation.name))
	}
	fname <- sprintf("%s/%03d.WGBS", genome.assembly@dir.assembly, i)
	result <- tryCatch(readRDS(fname), error = wgbs.null)
	if (!(is.integer(result) && length(result) != 0)) {
		stop(paste("Internal error: Missing or invalid file", fname))
	}
	if (simplified) {
		i <- genome.assembly@annotations[as.integer(genome.assembly@annotations[, 1] == i), 2]
		if (length(i) == 1) {
			result <- (result == 1L)
		} else {
			result <- factor(result, levels = 1:length(i))
			levels(result) <- i
		}
	}
	result
}

########################################################################################################################

#' Add an annotation
#'
#' Adds an annotation to the given genome assembly.
#'
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @param annotation.name One-element \code{character} vector specifying the name for the new annotation. This cannot be
#'                        \code{"strand"}, \code{"chromosome"}, or any other already defined annotations.
#' @param fname           Name of an existing BED file that defines genomic regions.
#' @return ...
#'
#' @seealso \code{\link{wgbs.get.annotations}} for listing all currently available annotatoins of a genome assembly.
#'
#' @author Yassen Assenov
#' @export
wgbs.add.annotation <- function(genome.assembly, annotation.name, fname) {
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	if (!(is.character(annotation.name) && length(annotation.name) == 1 && isTRUE(annotation.name != ""))) {
		stop("Invalid value for annotation.name")
	}
	if (!(is.character(fname) && length(fname) == 1 && isTRUE(fname != ""))) {
		stop("Invalid value for fname")
	}
	if (!isTRUE(file.info(fname)[, "isdir"] == FALSE)) {
		stop("Invalid value for fname; must be an existing file")
	}

	## Load the regions from a BED file
	#...

	## Overlap regions with CpG coordinates
	con.coordinates <- tryCatch(
		suppressWarnings(file(file.path(genome.assembly@dir.assembly, "001.WGBS"), "rb")),
		error = wgbs.null)
	chrom.offsets <- c(0L, cumsum(unname(wgbs.get.chrom.cpgs(genome.assembly))))
	for (i.chromosome in 1:length(chrom.names)) {
		cpg.coords <- wgbs.load.coordinates(con.coordinates, chrom.offsets[i.chromosome], offset)
		cpg.coords <- rep(cpg.coords, each = 2) + 0:1
		## TODO: ...
	}
	close(con.coordinates)
	rm(con.coordinates, chrom.offsets, i.chromosome, cpg.coords)

}

########################################################################################################################

#' Get CpGs per chromosome
#'
#' Gets the number of CpGs for each of the supported chromosomes.
#'
#' @param genome.assembly Targeted genome assembly, specified either as a name or an
#'                        \code{\linkS4class{AssemblyCpGs}} instance.
#' @return Named \code{integer} vector of non-negative values, storing number of CpGs per chromosome.
#'
#' @author Yassen Assenov
#' @noRd
wgbs.get.chrom.cpgs <- function(genome.assembly) {
	genome.assembly <- wgbs.get.assembly(genome.assembly)
	i <- which(genome.assembly@annotations[, 1] == "chromosome")
	result <- genome.assembly@annotations[i, 3]
	names(result) <- genome.assembly@annotations[i, 2]
	result
}
