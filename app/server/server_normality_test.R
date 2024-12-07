normality_test_server <- function(input, output, session, merged_data) {
  observeEvent(input$run_normality, {
    withProgress(message = 'Running normality test...', value = 0, {
      req(merged_data(), input$normality_protein)
      data_for_test <- merged_data() %>%
        filter(Assay == input$normality_protein)
      
      output$normality_plot <- renderPlot({
        ggplot(data_for_test, aes(x = NPX)) +
          geom_histogram(bins = 30, fill = "skyblue", color = "black") +
          ggtitle(paste("Distribution of", input$normality_protein)) +
          theme_minimal()
      })
      
      output$normality_test_result <- renderPrint({
        shapiro.test(data_for_test$NPX)
      })
      incProgress(1)
    })
  })
  
  output$download_normality_plot <- downloadHandler(
    filename = function() { paste("normality_plot_", input$normality_protein, "_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}