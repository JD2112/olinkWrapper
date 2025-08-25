violin_plot_server <- function(input, output, session, merged_data) {
  observeEvent(input$run_violin, {
    withProgress(message = 'Generating Violin plot...', value = 0, {
      req(merged_data(), input$violin_protein, input$violin_group)
      data_for_plot <- merged_data()
      
      if (input$violin_var_type == "Factor") {
        data_for_plot[[input$violin_group]] <- as.factor(data_for_plot[[input$violin_group]])
      } else {
        data_for_plot[[input$violin_group]] <- as.character(data_for_plot[[input$violin_group]])
      }
      
      plot_data <- data_for_plot %>%
        filter(Assay == input$violin_protein)
      
      output$violin_plot <- renderPlot({
        ggplot(plot_data, aes(x = !!sym(input$violin_group), y = NPX, fill = !!sym(input$violin_group))) +
          geom_violin(trim = FALSE) +
          geom_boxplot(width = 0.1, fill = "white") +
          labs(title = paste("Violin Plot for", input$violin_protein),
               x = input$violin_group,
               y = "NPX Value") +
          theme_minimal() +
          theme(legend.position = "none")
      })
      incProgress(1)
    })
  })
  
  output$download_violin <- downloadHandler(
    filename = function() { paste("violin_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}