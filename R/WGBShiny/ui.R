shinyUI(navbarPage(

	title = 'WGBS Benchmarking Results',
	tabPanel('Path', fluidPage(
		shinyjs::useShinyjs(),
		textInput("aPath", label = "Analysis results directory"),
		textOutput('aTitl', inline = FALSE)
	)),
	tabPanel('Pairwise comparisons', sidebarLayout(
		sidebarPanel(fluidPage(
			selectInput('pAnno', "Annotation", choices = character(), selectize = FALSE),
			selectInput('pStra', "Strand", choices = c("+", "-", "both"), selectize = FALSE),
			selectInput('sName', "Comparison", choices = c("beta values"), selectize = FALSE),
			selectInput('sPip1', "Pipeline 1", choices = character(), selectize = FALSE),
			selectInput('sPip2', "Pipeline 2", choices = character(), selectize = FALSE),
			sliderInput('iwid1', "Image width", 2, IMAGE.MAX, 4, 0.5),
			sliderInput('ihei1', "Image height", 2, IMAGE.MAX, 4, 0.5),
			downloadButton("down1", "Export image"))),
		mainPanel(fluidPage(
			plotOutput("pComp")
		)))),
	tabPanel('Metrics', sidebarLayout(
		sidebarPanel(fluidPage(
			selectInput('sAnno', "Annotation", choices = character(), selectize = FALSE),
			selectInput('sStra', "Strand", choices = c("+", "-", "both"), selectize = FALSE),
			selectInput('sMetr', "Metric", choices = character(), selectize = FALSE),
			sliderInput('iwid2', "Image width", 2, IMAGE.MAX, 4, 0.5),
			sliderInput('ihei2', "Image height", 2, IMAGE.MAX, 4, 0.5),
			downloadButton("down2", "Export image"))),
		mainPanel(fluidPage(
			plotOutput("pMetr")
		))))
))
