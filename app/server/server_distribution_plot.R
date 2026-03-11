distribution_plot_server <- function(input, output, session, merged_data, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Update input choices
  observe({
    req(merged_data())
    updateSelectInput(session, "dist_color_variable", choices = names(merged_data()))
  })
  
  # Generate distribution plot
  plot_data <- eventReactive(input$generate_dist_plot, {
    req(merged_data(), input$dist_color_variable)
    
    withProgress(message = 'Generating distribution plot...', value = 0, {
      # Generate plot using olink_dist_plot
      tryCatch({
        data_for_plot <- merged_data()
        if (input$dist_var_type == "Factor") {
          data_for_plot[[input$dist_color_variable]] <- as.factor(data_for_plot[[input$dist_color_variable]])
        } else {
          data_for_plot[[input$dist_color_variable]] <- as.character(data_for_plot[[input$dist_color_variable]])
        }
        
        plot <- do.call(olink_dist_plot, list(df = data_for_plot, color_g = input$dist_color_variable))
        
        # Log analysis
        log_analysis(analysis_log, "Distribution Plot", 
                     paste("Color by:", input$dist_color_variable, "| Type:", input$dist_var_type),
                     plot = plot)
        
        incProgress(1)
        plot
      }, error = function(e) {
        showNotification(paste("Error generating distribution plot:", e$message), type = "error")
        NULL
      })
    })
  })
  
  # Render distribution plot
  output$distribution_plot <- renderPlot({
    req(plot_data())
    plot_data()
  })
  
  # Download handler
  output$download_dist_plot <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_DistributionPlot_", input$dist_color_variable, "_", format(Sys.Date(), "%Y%m%d"), ".png")
    },
    content = function(file) {
      req(plot_data())
      ggsave(file, plot = plot_data(), device = "png", width = 10, height = 8)
    }
  )
}