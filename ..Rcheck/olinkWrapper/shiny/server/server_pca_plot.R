pca_plot_server <- function(input, output, session, merged_data, analysis_log) {
  # Reactive value to store the current plot
  current_plot <- reactiveVal(NULL)
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Update choices when data is loaded
  observe({
    req(merged_data())
    vars <- colnames(merged_data())
    updateSelectInput(session, "pca_var", choices = vars)
  })

  observeEvent(input$run_pca, {
    withProgress(message = 'Generating PCA plot...', value = 0, {
      req(merged_data(), input$pca_var)
      data_for_pca <- merged_data()
      
      if (input$pca_var_type == "Factor") {
        data_for_pca[[input$pca_var]] <- as.factor(data_for_pca[[input$pca_var]])
      } else if (input$pca_var_type == "Numeric") {
        data_for_pca[[input$pca_var]] <- as.numeric(data_for_pca[[input$pca_var]])
      } else {
        data_for_pca[[input$pca_var]] <- as.character(data_for_pca[[input$pca_var]])
      }
      
      p <- olink_pca_plot(data_for_pca, color_g = input$pca_var)
      
      if (input$label_pca) {
        # Check if SampleID exists
        if ("SampleID" %in% colnames(data_for_pca)) {
           p <- p + ggrepel::geom_text_repel(aes(label = SampleID))
        } else if ("Sample_ID" %in% colnames(data_for_pca)) {
           p <- p + ggrepel::geom_text_repel(aes(label = Sample_ID))
        }
      }
      
      current_plot(p)
      
      # Log analysis
      log_analysis(analysis_log, "PCA Plot", 
                   paste("Variable:", input$pca_var, "| Type:", input$pca_var_type),
                   plot = p)
      
      output$pca_plot <- renderPlot({ p })
      incProgress(1)
    })
  })
  
  output$download_pca <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_PCA_", input$pca_var, "_", format(Sys.Date(), "%Y%m%d"), ".png") 
    },
    content = function(file) {
      req(current_plot())
      # Ensure it's not a list (olink_pca_plot usually returns a ggplot, but safe to check)
      p <- current_plot()
      if (inherits(p, "list")) {
        p <- p[[1]]
      }
      ggsave(file, plot = p, device = "png", width = 10, height = 8)
    }
  )
}