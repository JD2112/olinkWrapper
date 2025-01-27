# umap server

umap_server <- function(input, output, session, merged_data) {
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    updateSelectInput(session, "umap_color_by", 
                      choices = names(merged_data()),
                      selected = "Group")
    updateSelectInput(session, "volcano_comparison", 
                      choices = unique(merged_data()$Group))
  })
  
  # UMAP Plot
  observeEvent(input$generate_umap, {
    withProgress(message = 'Generating UMAP plot...', value = 0, {
      req(merged_data(), input$umap_color_by, input$umap_var_type)
      data_for_umap <- merged_data()
      
      # Convert the color variable to the specified type
      if (input$umap_var_type == "Factor") {
        data_for_umap[[input$umap_color_by]] <- as.factor(data_for_umap[[input$umap_color_by]])
      } else if (input$umap_var_type == "Numeric") {
        data_for_umap[[input$umap_color_by]] <- as.numeric(data_for_umap[[input$umap_color_by]])
      } else {
        data_for_umap[[input$umap_color_by]] <- as.character(data_for_umap[[input$umap_color_by]])
      }
      
      output$umap_plot <- renderPlot({
        tryCatch({
          p <- olink_umap_plot(data_for_umap, 
                    color_g = input$umap_color_by,
                    label_samples = input$label_samples,
                    #label_outliers = input$label_outliers,
                    byPanel = TRUE)
          
          if (input$label_samples) {
            p <- p + ggrepel::geom_text_repel(aes(label = SampleID))
          }
          
          p
        }, error = function(e) {
          showNotification(paste("Error in UMAP generation:", e$message), type = "error")
          NULL
        })
      })
      incProgress(1)
    })
  })
  
  # Download handler for UMAP plot
  output$download_umap <- downloadHandler(
    filename = function() { paste("umap_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}