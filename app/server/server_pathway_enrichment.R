library(shiny)
library(DT)
library(OlinkAnalyze)
library(clusterProfiler)

pathway_enrichment_server <- function(input, output, session, merged_data, ttest_results, shared_enrichment_results) {
  
  print("Pathway Enrichment Server: Function started")
  
  # Print OlinkAnalyze version
  print(paste("OlinkAnalyze version:", packageVersion("OlinkAnalyze")))
  
  observe({
    print("Pathway Enrichment: Checking merged_data and ttest_results")
    print(paste("merged_data is null:", is.null(merged_data())))
    print(paste("ttest_results is null:", is.null(ttest_results())))
  })
  
  output$pathway_enrichment_content <- renderUI({
    req(ttest_results())
    print("Pathway Enrichment: Rendering UI")
    tagList(
      selectInput("enrichment_method", "Enrichment Method:", 
                  choices = c("GSEA", "ORA")),
      selectInput("ontology", "Ontology:",
                  choices = c("MSigDb", "Reactome", "KEGG", "GO")),
      selectInput("organism", "Organism:",
                  choices = c("human", "mouse", "rat")),
      numericInput("pvalue_cutoff", "P-value Cutoff:",
                   value = 0.05, min = 0, max = 1, step = 0.01),
      numericInput("estimate_cutoff", "Estimate Cutoff:",
                   value = 0, min = -Inf, max = Inf, step = 0.1),
      actionButton("run_enrichment", "Run Enrichment Analysis"),
      uiOutput("enrichment_spinner"),
      DTOutput("enrichment_results"),
      plotOutput("enrichment_plot"),
      downloadButton("download_enrichplot", "Download Plot", class = "btn-success")
    )
  })

  observeEvent(input$run_enrichment, {
    print("Pathway Enrichment: Run enrichment button clicked")
    req(merged_data(), ttest_results())
    
    withProgress(message = 'Running pathway enrichment analysis...', value = 0, {
      tryCatch({
        npx_data <- merged_data()
        test_results <- ttest_results()
        
        # Ensure consistency between npx_data and test_results
        common_olinkids <- intersect(unique(npx_data$OlinkID), test_results$OlinkID)
        npx_data <- npx_data[npx_data$OlinkID %in% common_olinkids, ]
        test_results <- test_results[test_results$OlinkID %in% common_olinkids, ]
        
        print("Pathway Enrichment: NPX data structure:")
        print(str(npx_data))
        
        print("Pathway Enrichment: T-test results structure:")
        print(str(test_results))
        
        print("Enrichment arguments:")
        print(list(
          data = npx_data,
          test_results = test_results,
          method = input$enrichment_method,
          ontology = input$ontology,
          organism = input$organism,
          pvalue_cutoff = input$pvalue_cutoff,
          estimate_cutoff = input$estimate_cutoff
        ))
        
        results <- olink_pathway_enrichment(
          data = npx_data,
          test_results = test_results,
          method = input$enrichment_method,
          ontology = input$ontology,
          organism = input$organism,
          pvalue_cutoff = input$pvalue_cutoff,
          estimate_cutoff = input$estimate_cutoff
        )
        
        print("Pathway Enrichment: Enrichment results structure:")
        print(str(results))
        
        shared_enrichment_results(results)
        
        incProgress(1)
        print("Pathway Enrichment: Analysis completed successfully")
      }, error = function(e) {
        print(paste("Pathway Enrichment: Full error message:", e$message))
        showNotification(paste("Error in pathway enrichment analysis:", e$message), type = "error")
      })
    })
  })
  
  output$enrichment_results <- renderDT({
    req(shared_enrichment_results())
    if (is.null(shared_enrichment_results())) {
      return(datatable(data.frame(Message = "No results available. Please run the analysis.")))
    }
    datatable(shared_enrichment_results(), 
              extensions = 'Buttons',
              options = list(
                paging = TRUE,
                searching = TRUE,
                fixedColumns = TRUE,
                autowidth = TRUE,
                ordering = TRUE,
                dom = 'Bflrtip',
                lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100','All')),
                scrollX = TRUE,
                buttons = list(
                  list(extend = "excel", text = "Download current page", 
                       filename = "Pathway Enrichment Analysis",
                       exportOptions = list(
                         modifier = list(page = "current")
                       ))))
    )
  })
  
  output$enrichment_plot <- renderPlot({
    req(shared_enrichment_results())
    if (input$enrichment_method == "GSEA") {
      olink_pathway_visualization(shared_enrichment_results())
    } else {  # ORA
      olink_pathway_heatmap(shared_enrichment_results())
    }
  })
  
  output$download_enrichment <- downloadHandler(
    filename = function() {
      paste("enrichment_results_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(shared_enrichment_results(), file, row.names = FALSE)
    }
  )

  output$download_enrichplot <- downloadHandler(
    filename = function() { paste("pathway_enrichment_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}