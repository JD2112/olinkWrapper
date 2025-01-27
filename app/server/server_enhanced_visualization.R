enhanced_visualization_server <- function(input, output, session, merged_data) {
  
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
          p <- olink_umap_plot(data_for_umap, coloroption = input$umap_color_by)
          
          if (input$label_umap) {
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
  
  # Volcano Plot
  observeEvent(input$generate_volcano, {
    req(merged_data(), input$volcano_comparison)
    
    withProgress(message = 'Generating volcano plot...', value = 0, {
      tryCatch({
        # Assuming you have t-test results
        # You may need to adjust this part based on your actual data structure
        ttest_results <- olink_ttest(merged_data(), 
                                     variable = "Group", 
                                     alternative = input$volcano_comparison)
        p <- olink_volcano_plot(ttest_results)
        output$volcano_plot <- renderPlot({ p })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in volcano plot generation:", e$message), type = "error")
      })
    })
  })
}