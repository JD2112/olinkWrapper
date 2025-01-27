distribution_plot_server <- function(input, output, session, merged_data) {
  
  # Update input choices
  observe({
    req(merged_data())
    updateSelectInput(session, "dist_color_variable", choices = names(merged_data()))
  })
  
  # Generate distribution plot
  plot_data <- eventReactive(input$generate_dist_plot, {
    req(merged_data(), input$dist_color_variable)
    
    # Print debug information
    print(paste("Selected color variable:", input$dist_color_variable))
    print(paste("Is color variable in merged_data:", input$dist_color_variable %in% names(merged_data())))
    
    # Generate plot using olink_dist_plot
    tryCatch({
      print("Generating distribution plot...")
      print(paste("Color variable:", input$dist_color_variable))
      
      # Convert the color variable to a symbol
      color_var <- rlang::sym(input$dist_color_variable)
      
      plot <- olink_dist_plot(merged_data(), color_g = !!color_var)
      print("Plot generated successfully")
      print(class(plot))
      plot
    }, error = function(e) {
      print(paste("Error in olink_dist_plot:", e$message))
      print("Merged data column names:")
      print(names(merged_data()))
      NULL
    })
  })
  
  # Render distribution plot
  output$distribution_plot <- renderPlot({
    req(plot_data())
    print("Rendering plot...")
    if (is.null(plot_data())) {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "Error generating distribution plot. Please check your data and selections.", cex = 1.2)
      text(0, -0.1, "Check the console for more details.", cex = 0.8)
    } else {
      print(class(plot_data()))
      print(plot_data())
    }
  })
  
  # Download handler
  output$download_dist_plot <- downloadHandler(
    filename = function() {
      paste("distribution_plot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      req(plot_data())
      ggsave(file, plot = plot_data(), device = "png", width = 10, height = 8)
    }
  )
}