pathway_heatmap_server <- function(input, output, session, shared_enrichment_results, ttest_results) {
  
  print("Pathway Heatmap Server: Function started")
  
  # Check if t-test and enrichment analysis have been run
  is_ready <- reactive({
    !is.null(ttest_results()) && !is.null(shared_enrichment_results())
  })
  
  # Update UI based on readiness
  observe({
    if (is_ready()) {
      shinyjs::enable("generate_pathway_heatmap")
      output$heatmap_status <- renderText("Ready to generate heatmap.")
    } else {
      shinyjs::disable("generate_pathway_heatmap")
      output$heatmap_status <- renderText("Please run t-test and pathway enrichment analysis first.")
    }
  })
  
  # Generate pathway heatmap
  pathway_heatmap_data <- eventReactive(input$generate_pathway_heatmap, {
    req(is_ready())
    print("Pathway Heatmap: Generate button clicked")
    
    # Check if the enrichment results contain a 'method' field
    if (!is.null(shared_enrichment_results()) && "method" %in% names(shared_enrichment_results())) {
      enrich_method <- shared_enrichment_results()$method
      if (input$pathway_heatmap_method != enrich_method) {
        showNotification(paste("Please select", enrich_method, "as the enrichment method."), type = "warning")
        return(NULL)
      }
    } else {
      print("Warning: Enrichment results do not contain a 'method' field.")
    }
    
    print(paste("Enrichment results rows:", nrow(shared_enrichment_results())))
    print(paste("T-test results rows:", nrow(ttest_results())))
    
    # Generate heatmap using olink_pathway_heatmap
    tryCatch({
      print("Generating pathway heatmap...")
      print(paste("Method:", input$pathway_heatmap_method))
      print(paste("Keyword:", input$pathway_heatmap_keyword))
      print(paste("Number of terms:", input$pathway_heatmap_number_of_terms))
      
      keyword <- if(input$pathway_heatmap_keyword != "") input$pathway_heatmap_keyword else NULL
      
      heatmap <- olink_pathway_heatmap(
        enrich_results = shared_enrichment_results(),
        test_results = ttest_results(),
        method = input$pathway_heatmap_method,
        keyword = keyword,
        number_of_terms = input$pathway_heatmap_number_of_terms
      )
      print("Pathway heatmap generated successfully")
      print(paste("Class of heatmap:", class(heatmap)))
      heatmap
    }, error = function(e) {
      print(paste("Error in olink_pathway_heatmap:", e$message))
      print("Enrichment results structure:")
      print(str(shared_enrichment_results()))
      print("T-test results structure:")
      print(str(ttest_results()))
      showNotification(paste("Error generating heatmap:", e$message), type = "error")
      NULL
    })
  })
  
  # Render pathway heatmap
  output$pathway_heatmap_plot <- renderPlot({
    req(pathway_heatmap_data())
    print("Rendering pathway heatmap...")
    if (is.null(pathway_heatmap_data())) {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "Error generating pathway heatmap. Please check your data and selections.", cex = 1.2)
      text(0, -0.1, "Check the console for more details.", cex = 0.8)
    } else {
      print("Displaying pathway heatmap")
      pathway_heatmap_data()
    }
  })
  
  # Download handler
  output$download_pathway_heatmap <- downloadHandler(
    filename = function() {
      paste("pathway_heatmap_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      req(pathway_heatmap_data())
      ggsave(file, plot = pathway_heatmap_data(), device = "png", width = 12, height = 10)
    }
  )
}