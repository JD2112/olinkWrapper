pca_plot_server <- function(input, output, session, merged_data) {
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
      
      output$pca_plot <- renderPlot({
        p <- olink_pca_plot(data_for_pca, color_g = input$pca_var)
        
        if (input$label_pca) {
          p <- p + ggrepel::geom_text_repel(aes(label = SampleID))
        }
        
        p
      })
      incProgress(1)
    })
  })
  
  output$download_pca <- downloadHandler(
    filename = function() { paste("pca_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}