library(WGBS)
context("BisulfiteCalls initialization")

assembly <- wgbs.load.toy.assembly()

test_that("Pipelne 1 is valid", {
	## Construct the pipeline results object
	dir.calls <- tempfile("pipeline")
	expect_false(file.exists(dir.calls))
	fname <- system.file("extdata/pipeline1.txt", package = "WGBS")
	expect_true(file.exists(fname))
	pipeline.name <- "Pipeline 1"
	bcalls <- wgbs.import.pipeline.results(fname, assembly, dir.calls, pipeline.name, FALSE)
	rm(dir.calls, fname)

	## Validate the object's structure
	expect_equal(bcalls@title, pipeline.name)
	expect_equal(length(bcalls@chromosomes), 3L)
	expect_equal(names(bcalls@chromosomes), c("1", "2", "X"))

	## Clean up
	invisible(unlink(bcalls@dir.calls, TRUE, TRUE))
})
