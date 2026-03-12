enhanced_visualization_server <- function(input, output, session, merged_data) {
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    cols <- names(merged_data())
    
    # Use Group if available, otherwise first column
    sel_color <- if ("Group" %in% cols) "Group" else cols[1]
    
    updateSelectInput(session, "umap_color_by", 
                      choices = cols,
                      selected = sel_color)
                      
    if ("Group" %in% cols) {
      updateSelectInput(session, "volcano_comparison", 
                        choices = unique(merged_data()$Group))
    }
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
          
          if (isTRUE(input$label_umap)) {
            # Try to find a sensible label column
            lbl_col <- if ("SampleID" %in% colnames(data_for_umap)) "SampleID" else if ("Sample_ID" %in% colnames(data_for_umap)) "Sample_ID" else NULL
            if (!is.null(lbl_col)) {
              p <- p + ggrepel::geom_text_repel(aes(label = !!sym(lbl_col)))
            }
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
      # Use ggsave safely
      ggsave(file, device = "png", width = 10, height = 8)
    }
  )
  
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
  
  # Volcano Plot (Manual/Legacy version)
  observeEvent(input$generate_volcano, {
    req(merged_data(), input$volcano_comparison)
    
    withProgress(message = 'Generating volcano plot...', value = 0, {
      tryCatch({
        # Check if Group column exists for this legacy test
        if (!"Group" %in% colnames(merged_data())) {
          stop("Legacy volcano plot requires a column named 'Group'.")
        }

        ttest_results <- olink_ttest(merged_data(), 
                                     variable = "Group", 
                                     alternative = input$volcano_comparison)
        if (nrow(ttest_results) == 0) stop("T-test returned no results.")
        
        p <- olink_volcano_plot(ttest_results)
        output$volcano_plot <- renderPlot({ p })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in volcano plot generation:", e$message), type = "error")
      })
    })
  })
}