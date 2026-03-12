library(shiny)
library(DT)
library(OlinkAnalyze)
library(clusterProfiler)

pathway_enrichment_server <- function(input, output, session, merged_data, ttest_results, shared_enrichment_results, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  output$pathway_enrichment_content <- renderUI({
    req(ttest_results())
    tagList(
      # Row 1: The Settings (3 Columns)
      fluidRow(
        column(4,
          selectInput("enrichment_method", "Enrichment Method:", 
                      choices = c("GSEA", "ORA")),
          numericInput("pvalue_cutoff", "P-value Cutoff:",
                      value = 0.05, min = 0, max = 1, step = 0.01)
        ),
        column(4,
          selectInput("ontology", "Ontology:",
                      choices = c("MSigDb", "Reactome", "KEGG", "GO")),
          numericInput("estimate_cutoff", "Estimate Cutoff:",
                      value = 0, min = -Inf, max = Inf, step = 0.1)
        ),
        column(4,
          selectInput("organism", "Organism:",
                      choices = c("human", "mouse", "rat")),
          div(style = "margin-top: 25px;", 
              actionButton("run_enrichment", "Run Enrichment Analysis", 
                          class = "btn-primary", width = "100%"))
        )
      ),
      
      hr(), 
      
      # Row 2: Results Table
      fluidRow(
        column(12,
          DTOutput("enrichment_results")
        )
      ),
      
      # Row 3: Visualization
      fluidRow(
        column(12,
          plotOutput("enrichment_plot"),
          br(),
          downloadButton("download_enrichplot", "Download Plot", class = "btn-success")
        )
      )
    )
  })

  # Reactive for plot
  enrich_plot_rv <- reactiveVal(NULL)

  observeEvent(input$run_enrichment, {
    req(merged_data(), ttest_results())
    
    withProgress(message = 'Running pathway enrichment analysis...', value = 0, {
      tryCatch({
        npx_data <- merged_data()
        test_results <- ttest_results()
        
        # Ensure consistency
        common_olinkids <- intersect(unique(npx_data$OlinkID), test_results$OlinkID)
        npx_data <- npx_data[npx_data$OlinkID %in% common_olinkids, ]
        test_results <- test_results[test_results$OlinkID %in% common_olinkids, ]
        
        results <- olink_pathway_enrichment(
          data = npx_data,
          test_results = test_results,
          method = input$enrichment_method,
          ontology = input$ontology,
          organism = input$organism,
          pvalue_cutoff = input$pvalue_cutoff,
          estimate_cutoff = input$estimate_cutoff
        )
        
        shared_enrichment_results(results)
        
        # Visualization
        p <- tryCatch({
          if (input$enrichment_method == "GSEA") {
            olink_pathway_visualization(results)
          } else {  # ORA
            olink_pathway_heatmap(results)
          }
        }, error = function(e) NULL)
        
        enrich_plot_rv(p)
        
        # Log analysis
        log_analysis(analysis_log, "Pathway Enrichment", 
                     paste("Method:", input$enrichment_method, "| Ontology:", input$ontology, "| Organism:", input$organism),
                     plot = p,
                     table = results)
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in pathway enrichment analysis:", e$message), type = "error")
      })
    })
  })
  
  output$enrichment_results <- renderDT({
    req(shared_enrichment_results())
    datatable(shared_enrichment_results(), 
              extensions = 'Buttons',
              options = list(
                paging = TRUE,
                searching = TRUE,
                fixedColumns = TRUE,
                autowidth = TRUE,
                ordering = TRUE,
                dom = 'Bflrtip',
                buttons = list(
                  list(extend = "excel", 
                       text = "Download current page", 
                       filename = paste0("olinkWrapper_", VERSION, "_PathwayEnrichment_", input$enrichment_method, "_", input$ontology, "_", input$organism, "_", format(Sys.Date(), "%Y%m%d")),
                       exportOptions = list(modifier = list(page = "current"))))
              )
    )
  })
  
  output$enrichment_plot <- renderPlot({
    req(enrich_plot_rv())
    enrich_plot_rv()
  })
  
  output$download_enrichplot <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_PathwayEnrich_Plot_", input$enrichment_method, "_", input$ontology, "_", input$organism, "_", format(Sys.Date(), "%Y%m%d"), ".png") 
    },
    content = function(file) {
      req(enrich_plot_rv())
      ggsave(file, plot = enrich_plot_rv(), device = "png", width = 12, height = 10)
    }
  )
}