shinyServer(function(input, output, session) {

	data <- reactive({
		result <- tryCatch(
			suppressWarnings(readRDS(file.path(input$aPath, "index.RDS"))),
			error = WGBS:::wgbs.null)
		if (!is.null(result)) {
			updateSelectInput(session, 'sMetr', choices = result$metrics[, "Name"])
			result$anno <- paste0("(", result$annotations[, 1], ") ", result$annotations[, 2])
			result$anno <- c("whole genome", result$anno)
			updateSelectInput(session, 'pAnno', choices = result$anno)
			updateSelectInput(session, 'sAnno', choices = result$anno)
			updateSelectInput(session, 'sPip1', choices = result$pipelines)
			updateSelectInput(session, 'sPip2', choices = result$pipelines)
		}
		result
	})

	output$aTitl <- renderText({
		result <- data()
		if (is.list(result)) {
			shinyjs::disable('aPath')
			return(paste(nrow(result$metrics), "metrics on", nlevels(result$annotations[, 1]), "annotations"))
		}
	})

	output$pComp <- renderPlot({
		x <- data()
		i.anno <- which(x$anno == input$sAnno) - 1L
		load(sprintf("%s/M%03d.RData", input$aPath, i.anno)) # -> tbls.agreements, results
		pipelines <- c(input$sPip1, input$sPip2)
		ii <- sapply(pipelines, function(pn) { which(x$pipelines == pn) })
		if (ii[1] == ii[2]) {
			results <- EMPTY.PLOT
		} else {
			swap.axes <- (ii[1] >= ii[2])
			dframe <- tbls.agreements[[paste0(paste0(sort(ii), collapse = ":"), ":", input$sStra)]]
			if (is.null(dframe)) {
				result <- EMPTY.PLOT				
			} else {
				results <- WGBS:::wgbs.plot.agreement.bins(dframe, pipelines[1], pipelines[2], swap.axes)
			}
		}
		results
	})
	
})
