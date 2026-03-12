# umap server

umap_server <- function(input, output, session, merged_data, analysis_log) {
  # Reactive value to store the current plot
  current_plot <- reactiveVal(NULL)
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    cols <- names(merged_data())
    
    default_color <- if ("Group" %in% cols) "Group" else cols[1]
    updateSelectInput(session, "umap_color_by", 
                      choices = cols,
                      selected = default_color)
                      
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
      
      p_res <- tryCatch({
        p <- olink_umap_plot(data_for_umap, 
                  color_g = input$umap_color_by,
                  label_samples = input$label_samples,
                  byPanel = TRUE)
        
        # If byPanel=TRUE, olink_umap_plot returns a list of plots.
        # We need to handle this for display and download.
        # If it's a list, we display the first one or a grid.
        if (inherits(p, "list")) {
           # If multiple panels, cowplot can combine them.
           # But for display we might just take the first or use print.
           p_final <- cowplot::plot_grid(plotlist = p)
           p_final
        } else {
           if (input$label_samples) {
             # Check if SampleID exists
             if ("SampleID" %in% colnames(data_for_umap)) {
                p <- p + ggrepel::geom_text_repel(aes(label = SampleID))
             } else if ("Sample_ID" %in% colnames(data_for_umap)) {
                p <- p + ggrepel::geom_text_repel(aes(label = Sample_ID))
             }
           }
           p
        }
      }, error = function(e) {
        showNotification(paste("Error in UMAP generation:", e$message), type = "error")
        NULL
      })

      if (!is.null(p_res)) {
        current_plot(p_res)
        # Log analysis
        log_analysis(analysis_log, "UMAP Plot", 
                     paste("Color by:", input$umap_color_by, "| Type:", input$umap_var_type),
                     plot = p_res)
        
        output$umap_plot <- renderPlot({ 
           if (inherits(p_res, "list")) {
              cowplot::plot_grid(plotlist = p_res)
           } else {
              p_res
           }
        })
      }
      
      incProgress(1)
    })
  })
  
  # Download handler for UMAP plot
  output$download_umap <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_UMAP_", input$umap_color_by, "_", format(Sys.Date(), "%Y%m%d"), ".png") 
    },
    content = function(file) {
      req(current_plot())
      p <- current_plot()
      # If it's a list (from byPanel), use plot_grid to save all panels in one file.
      if (inherits(p, "list")) {
         p <- cowplot::plot_grid(plotlist = p)
      }
      ggsave(file, plot = p, device = "png", width = 12, height = 10)
    }
  )
}