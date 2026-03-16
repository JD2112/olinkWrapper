qc_plot_server <- function(input, output, session, merged_data, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Update color_g choices based on available columns in merged_data
  observe({
    req(merged_data())
    updateSelectInput(session, "qc_color_g", choices = c("None", names(merged_data())))
  })
  
  # Generate QC plot
  qc_plot_data <- eventReactive(input$generate_qc_plot, {
    req(merged_data())
    
    tryCatch({
      color_g_param <- if(input$qc_color_g == "None") NULL else input$qc_color_g
      plot_data <- merged_data()
      
      # Convert the selected column to factor or character
      if (!is.null(color_g_param)) {
        if (input$qc_var_type == "Factor") {
          plot_data[[color_g_param]] <- as.factor(plot_data[[color_g_param]])
        } else {
          plot_data[[color_g_param]] <- as.character(plot_data[[color_g_param]])
        }
      }
      
      plot_args <- list(
        df = plot_data,
        label_outliers = input$qc_label_outliers,
        IQR_outlierDef = input$qc_IQR_outlierDef,
        median_outlierDef = input$qc_median_outlierDef,
        outlierLines = input$qc_outlierLines,
        facetNrow = if(is.na(input$qc_facetNrow)) NULL else input$qc_facetNrow,
        facetNcol = if(is.na(input$qc_facetNcol)) NULL else input$qc_facetNcol
      )
      
      if (!is.null(color_g_param)) {
        plot_args$color_g <- color_g_param
      }
      
      plot <- do.call(olink_qc_plot, plot_args)
      
      # Log analysis
      log_analysis(analysis_log, "QC Plot", 
                   paste("Color by:", input$qc_color_g, "| IQR Def:", input$qc_IQR_outlierDef),
                   plot = plot)
      
      plot
    }, error = function(e) {
      showNotification(paste("Error generating QC plot:", e$message), type = "error")
      NULL
    })
  })
  
  # Render QC plot
  output$qc_plot <- renderPlot({
    req(qc_plot_data())
    qc_plot_data()
  })
  
  # Download handler
  output$download_qc_plot <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_QCPlot_", input$qc_color_g, "_", format(Sys.Date(), "%Y%m%d"), ".png")
    },
    content = function(file) {
      req(qc_plot_data())
      ggsave(file, plot = qc_plot_data(), device = "png", width = 12, height = 10)
    }
  )
}