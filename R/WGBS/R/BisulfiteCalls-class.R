########################################################################################################################
## BisulfiteCalls-class.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Definition of the BisulfiteCalls class and its validation method.
########################################################################################################################

## C L A S S ###########################################################################################################

#' Bisulfite calls
#'
#' Manages the storage and access to methylation calls obtained by bisulfite convertion sequencing assay.
#'
#' @name BisulfiteCalls-class
#' @rdname BisulfiteCalls-class
#' @author Yassen Assenov
#' @exportClass BisulfiteCalls
setClass("BisulfiteCalls",
	representation(
		dir.calls = "character",
		title = "character",
		assembly = "character",
		chromosomes = "integer"),
	prototype(
		dir.calls = ".",
		title = "Results",
		assembly = "hg19",
		chromosomes = integer()),
	package = "WGBS")

## V A L I D A T I O N #################################################################################################

setValidity(
	"BisulfiteCalls",
	function(object) {
		if (!(length(object@dir.calls) == 1 && isTRUE(object@dir.calls != ""))) {
			return("Invalid value for dir.calls")
		}
		if (!isTRUE(file.info(object@dir.calls)[, "isdir"])) {
			return("Invalid value for dir.calls; expected an existing directory")
		}
		if (!(length(object@title) == 1 && isTRUE(object@title != ""))) {
			return("Invalid value for title")
		}
		if (!(length(object@assembly) == 1 && isTRUE(object@assembly != ""))) {
			return("Invalid value for assembly")
		}
		genome.assembly <- wgbs.get.assembly(object@assembly)
		genome.chromosomes <- wgbs.get.chrom.cpgs(genome.assembly) * 2L
		if (!identical(names(object@chromosomes), names(genome.chromosomes))) {
			return("Invalid value for chromosomes")
		}
		if (any(is.na(object@chromosomes))) {
			return("Invalid value for chromosomes")
		}
		if (any(object@chromosomes < 0 | object@chromosomes > genome.chromosomes)) {
			return("Invalid value for chromosomes")
		}
		TRUE
	}
)
