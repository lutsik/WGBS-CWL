########################################################################################################################
## AssemblyCpGs-class.R
## creator: Yassen Assenov
## ---------------------------------------------------------------------------------------------------------------------
## Definition of the AssemblyCpGs class and its validation method.
########################################################################################################################

## G L O B A L S #######################################################################################################

EMPTY.ANNOTATIONS <- data.frame(
	"Name" = factor(character(), levels = "chromosome"),
	"Category" = character(),
	"Size" = integer(), stringsAsFactors = FALSE)

## C L A S S ###########################################################################################################

#' Genome assembly CpGs
#'
#' Manages the storage and access to CpGs within a genomic assembly that are covered by the \pkg{WGBS} package.
#'
#' @section Slots:
#' \describe{
#'   \item{\code{dir.assembly}}{Directory containing the required data.}
#'   \item{\code{annotations}}{Table of annotations, as well as the categories they separate the CpGs into.}
#' }
#'
#' @section Construction and loading:
#' \describe{
#'   \item{\code{\link{wgbs.load.assembly}}}{Load and register an assembly.}
#'   \item{\code{\link{wgbs.get.assembly}}}{Retrieve a registered assembly.}
#' }
#'
#' @section Methods and functions:
#' \describe{
#'   \item{\code{\link{wgbs.assembly}}}{Get the assembly name.}
#'   \item{\code{\link{wgbs.get.chromosomes}}}{Get the supported chromosomes.}
#'   \item{\code{\link{wgbs.get.annotations}}}{Get the supported CpG annotations.}
#' }
#'
#' @name AssemblyCpGs-class
#' @rdname AssemblyCpGs-class
#' @author Yassen Assenov
#' @exportClass AssemblyCpGs
setClass("AssemblyCpGs",
		 representation(
		 	dir.assembly = "character", annotations = "data.frame"),
		 prototype(
		 	dir.assembly = ".", annotations = EMPTY.ANNOTATIONS),
		 package = "WGBS")

## V A L I D A T I O N #################################################################################################

setValidity(
	"AssemblyCpGs",
	function(object) {
		x <- object@dir.assembly
		if (!(is.character(x) && length(x) == 1 && isTRUE(x != ""))) {
			return("dir.assembly must be a one-element character vector")
		}
		if (!isTRUE(file.info(x)[, "isdir"])) {
			return("dir.assembly is not an existing directory")
		}
		x <- object@annotatons
		if (!(is.data.frame(x) && identical(sapply(x, class), sapply(EMPTY.ANNOTATIONS, class)))) {
			x <- paste(colnames(EMPTY.ANNOTATIONS), collapse = ", ")
			return(paste("annotations must be a data.frame with columns:", x))
		}
		if (!("chromosome" %in% levels(x[, 1]))) {
			return("Missing required annotation: chromosome")
		}
		TRUE
	}
)
