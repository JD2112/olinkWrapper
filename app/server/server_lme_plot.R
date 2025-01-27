lme_plot_server <- function(input, output, session, merged_data) {
  
  # Update input choices
  observe({
    req(merged_data())
    updateSelectizeInput(session, "lme_plot_olinkid_list", choices = unique(merged_data()$OlinkID))
    updateSelectizeInput(session, "lme_plot_variable", choices = names(merged_data()))
    updateSelectInput(session, "lme_plot_random", choices = names(merged_data()))
    updateSelectInput(session, "lme_plot_x_axis_variable", choices = names(merged_data()))
    updateSelectInput(session, "lme_plot_col_variable", choices = names(merged_data()))
  })
  
  # Generate LME plot
  lme_plot_data <- eventReactive(input$generate_lme_plot, {
    req(merged_data(), input$lme_plot_variable, input$lme_plot_random, input$lme_plot_x_axis_variable, input$lme_plot_col_variable)
    
    # Generate plot using olink_lmer_plot
    tryCatch({
      print("Generating LME plot...")
      print(paste("Variables:", paste(input$lme_plot_variable, collapse = ", ")))
      print(paste("Random Effect:", input$lme_plot_random))
      print(paste("X-axis Variable:", input$lme_plot_x_axis_variable))
      print(paste("Color Variable:", input$lme_plot_col_variable))
      
      plot <- olink_lmer_plot(
        df = merged_data(),
        olinkid_list = if(length(input$lme_plot_olinkid_list) > 0) input$lme_plot_olinkid_list else NULL,
        variable = input$lme_plot_variable,
        x_axis_variable = input$lme_plot_x_axis_variable,
        col_variable = input$lme_plot_col_variable,
        random = input$lme_plot_random
      )
      print("Plot generated successfully")
      print(class(plot))
      plot
    }, error = function(e) {
      print(paste("Error in olink_lmer_plot:", e$message))
      NULL
    })
  })
  
  # Render LME plot
  output$lme_plot_output <- renderPlot({
    req(lme_plot_data())
    print("Rendering LME plot...")
    if (is.null(lme_plot_data())) {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "Error generating LME plot. Please check your data and selections.", cex = 1.2)
      text(0, -0.1, "Check the console for more details.", cex = 0.8)
    } else {
      print(class(lme_plot_data()))
      print(lme_plot_data())
    }
  })
  
  # Download handler
output$download_lme_plot <- downloadHandler(
  filename = function() {
    paste("lme_plot_summary_", Sys.Date(), ".png", sep = "")
  },
  content = function(file) {
    req(lme_plot_data())
    tryCatch({
      if (inherits(lme_plot_data(), "list") && length(lme_plot_data()) > 0) {
        # Get the last plot from the list
        last_plot <- lme_plot_data()[[length(lme_plot_data())]]
        
        if (inherits(last_plot, "ggplot")) {
          ggsave(file, plot = last_plot, device = "png", width = 10, height = 8)
          print("Summary plot saved successfully")
        } else {
          stop("The last plot is not a ggplot object")
        }
      } else if (inherits(lme_plot_data(), "ggplot")) {
        # If it's a single ggplot object, save it directly
        ggsave(file, plot = lme_plot_data(), device = "png", width = 10, height = 8)
        print("Plot saved successfully")
      } else {
        stop("The plot object is not in the expected format")
      }
    }, error = function(e) {
      print(paste("Error saving plot:", e$message))
    })
  }
)
}