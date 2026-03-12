quality_control_server <- function(input, output, session, merged_data) {
  
  # Update UI choices based on available data
  observe({
    data <- merged_data()
    req(data)
    updateSelectInput(session, "qc_x_var", choices = names(data))
    updateSelectInput(session, "qc_y_var", choices = names(data))
    updateSelectInput(session, "qc_color_by", choices = c("None" = "", names(data)))
    updateSelectInput(session, "dist_panel", choices = unique(data$Panel))
  })
  
  # QC Scatterplot
  observeEvent(input$generate_qc_plot, {
    data <- merged_data()
    req(data, input$qc_x_var, input$qc_y_var)
    
    withProgress(message = 'Generating QC plot...', value = 0, {
      tryCatch({
        # Create the base plot
        p <- olink_qc_plot(data)
        
        # Customize the plot based on user selections
        p <- p + 
          aes_string(x = input$qc_x_var, y = input$qc_y_var) +
          labs(x = input$qc_x_var, y = input$qc_y_var)
        
        # Add color if selected
        if (!is.null(input$qc_color_by) && input$qc_color_by != "") {
          p <- p + aes_string(color = input$qc_color_by)
        }
        
        output$qc_plot <- renderPlot({ p })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in QC plot generation:", e$message), type = "error")
      })
    })
  })
  
  # NPX Distribution Plot
  observeEvent(input$generate_dist_plot, {
    data <- merged_data()
    req(data, input$dist_panel)
    
    withProgress(message = 'Generating distribution plot...', value = 0, {
      tryCatch({
        # Filter data for the selected panel
        panel_data <- data %>% 
          filter(Panel == input$dist_panel)
        
        p <- olink_dist_plot(panel_data)
        
        # Apply log scale if selected
        if (input$dist_log_scale) {
          p <- p + scale_y_log10()
        }
        
        output$dist_plot <- renderPlot({ p })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in distribution plot generation:", e$message), type = "error")
      })
    })
  })
}