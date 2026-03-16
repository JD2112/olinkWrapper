heatmap_server <- function(input, output, session, merged_data, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Reactive value to store the current heatmap plot
  current_heatmap <- reactiveVal(NULL)
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    # Heatmap specific choices would go here if needed. 
    # Removed umap_color_by and volcano_comparison updates as they belong to their respective modules.
  })

# Heatmap
  observeEvent(input$generate_heatmap, {
    req(merged_data(), input$heatmap_type)
    
    withProgress(message = 'Generating heatmap...', value = 0, {
      tryCatch({
        data_subset <- merged_data()
        
        if (input$heatmap_type == "All Samples and Proteins") {
          p <- olink_heatmap_plot(data_subset, 
                                  title = input$heatmap_title,
                                  x_lab = input$heatmap_x_axis,
                                  y_lab = input$heatmap_y_axis)
        } else {
          p <- olink_heatmap_plot(data_subset, 
                                  type = "module-trait",
                                  title = input$heatmap_title,
                                  x_lab = input$heatmap_x_axis,
                                  y_lab = input$heatmap_y_axis)
        }
        
        current_heatmap(p)
        
        # Log analysis
        log_analysis(analysis_log, "Heatmap", 
                     paste("Type:", input$heatmap_type, "| Title:", input$heatmap_title),
                     plot = p)
        
        n_samples <- length(unique(data_subset$SampleID))
        n_proteins <- length(unique(data_subset$Assay))
        
        output$heatmap_plot <- renderPlot({ 
          p 
        }, height = function() {
          min(max(400, n_samples * 10), 2000) 
        }, width = function() {
          min(max(600, n_proteins * 15), 3000) 
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in heatmap generation:", e$message), type = "error")
      })
    })
  })

  # Download handler for heatmap plot
  output$download_heatmap <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_Heatmap_", format(Sys.Date(), "%Y%m%d"), ".png") 
    },
    content = function(file) {
      req(current_heatmap())
      ggsave(file, plot = current_heatmap(), device = "png", width = 12, height = 10, dpi = 300)
    }
  )
}