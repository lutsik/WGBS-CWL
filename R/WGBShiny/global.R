## L I B R A R I E S ###################################################################################################

suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinyjs))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(WGBS))
theme_set(theme_bw())

## G L O B A L S #######################################################################################################

## Maximum widht or height of an image, in inches
IMAGE.MAX <- 12

EMPTY.PLOT <- ggplot(data.frame(x = 1, y = 1, labeltext = "Not available")) +
	aes_string("x", "y", label = "labeltext") + geom_text(color = "grey50") +
	theme(axis.line = element_blank(), axis.title = element_blank(), axis.text = element_blank()) +
	theme(axis.ticks = element_blank(), panel.border = element_blank(), panel.grid = element_blank()) +
	theme(panel.background = element_blank(), plot.background = element_blank())
