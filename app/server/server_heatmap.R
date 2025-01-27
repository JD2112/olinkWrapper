# heatmap plot server

heatmap_server <- function(input, output, session, merged_data) {
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    updateSelectInput(session, "umap_color_by", 
                      choices = names(merged_data()),
                      selected = "Group")
    updateSelectInput(session, "volcano_comparison", 
                      choices = unique(merged_data()$Group))
  })

# Heatmap
  observeEvent(input$generate_heatmap, {
    req(merged_data(), input$heatmap_type)
    
    withProgress(message = 'Generating heatmap...', value = 0, {
      tryCatch({
        # Subset data based on user inputs
        data_subset <- merged_data()
        
        if (input$heatmap_type == "All Samples and Proteins") {
          p <- olink_heatmap_plot(data_subset, 
                                  title = input$heatmap_title,
                                  x_lab = input$heatmap_x_axis,
                                  y_lab = input$heatmap_y_axis)
        } else {
          # Assuming you have module-trait relationship data
          # You may need to adjust this part based on your actual data structure
          p <- olink_heatmap_plot(data_subset, 
                                  type = "module-trait",
                                  title = input$heatmap_title,
                                  x_lab = input$heatmap_x_axis,
                                  y_lab = input$heatmap_y_axis)
        }
        
        # Adjust plot size based on the number of samples and proteins
        n_samples <- length(unique(data_subset$SampleID))
        n_proteins <- length(unique(data_subset$Assay))
        
        output$heatmap_plot <- renderPlot({ 
          p 
        }, height = function() {
          min(max(400, n_samples * 10), 2000)  # Adjust these values as needed
        }, width = function() {
          min(max(600, n_proteins * 15), 3000)  # Adjust these values as needed
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in heatmap generation:", e$message), type = "error")
      })
    })
  })

  # Download handler for UMAP plot
  output$download_umap <- downloadHandler(
    filename = function() { paste("Heatmap_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )

}