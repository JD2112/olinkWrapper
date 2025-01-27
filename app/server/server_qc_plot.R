qc_plot_server <- function(input, output, session, merged_data) {
  
  # Update color_g choices based on available columns in merged_data
  observe({
    req(merged_data())
    updateSelectInput(session, "qc_color_g", choices = c("None", names(merged_data())))
  })
  
  # Generate QC plot
  qc_plot_data <- eventReactive(input$generate_qc_plot, {
    req(merged_data())
    
    tryCatch({
      print("Generating QC plot...")
      print(paste("Selected color_g:", input$qc_color_g))
      
      # If "None" is selected, don't pass color_g parameter
      color_g_param <- if(input$qc_color_g == "None") NULL else input$qc_color_g
      
      # Create a copy of the data to modify
      plot_data <- merged_data()
      
      # Convert the selected column to factor or character based on user input
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
      
      # Only add color_g if it's not NULL
      if (!is.null(color_g_param)) {
        plot_args$color_g <- color_g_param
      }
      
      do.call(olink_qc_plot, plot_args)
    }, error = function(e) {
      print(paste("Error in olink_qc_plot:", e$message))
      print("Merged data structure:")
      print(str(merged_data()))
      showNotification(paste("Error generating QC plot:", e$message), type = "error")
      NULL
    })
  })
  
  # Render QC plot
  output$qc_plot <- renderPlot({
    req(qc_plot_data())
    print("Rendering QC plot...")
    qc_plot_data()
  })
  
  # Download handler
  output$download_qc_plot <- downloadHandler(
    filename = function() {
      paste("qc_plot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      req(qc_plot_data())
      ggsave(file, plot = qc_plot_data(), device = "png", width = 12, height = 10)
    }
  )
}