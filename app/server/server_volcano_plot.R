library(ggrepel)

volcano_plot_server <- function(input, output, session, merged_data, ttest_results, anova_results, wilcox_results, analysis_log) {
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Reactive value to store the current plot
  current_plot <- reactiveVal(NULL)

  observeEvent(input$run_volcano, {
    withProgress(message = "Generating Volcano plot...", value = 0, {
      tryCatch({
        # 1. Select the base results
        if (input$volcano_plot_type == "ttest") {
          req(ttest_results())
          results <- ttest_results()
        } else if (input$volcano_plot_type == "anova") {
          req(anova_results())
          results <- anova_results()$results
        } else if (input$volcano_plot_type == "wilcox") {
          req(wilcox_results())
          results <- wilcox_results()
        } else {
          showNotification("Invalid plot type selected.", type = "error")
          return()
        }
        
        # 2. Extract user choices
        p_col <- input$volcano_p_val_type 
        p_threshold <- input$volcano_p_threshold
        
        # 3. Create a clean plotting dataframe
        plot_df <- results
        
        if (!"estimate" %in% colnames(plot_df)) {
           if ("statistic" %in% colnames(plot_df)) {
             plot_df$estimate <- plot_df$statistic
           } else if ("estimate_median_diff" %in% colnames(plot_df)) {
             plot_df$estimate <- plot_df$estimate_median_diff
           } else {
             plot_df$estimate <- 0
           }
        }
        
        plot_df$Selected_P <- plot_df[[p_col]]
        plot_df$Selected_P <- ifelse(plot_df$Selected_P <= 0, 1e-300, plot_df$Selected_P)
        plot_df$Significance_Status <- ifelse(plot_df$Selected_P < p_threshold, "Significant", "Non-significant")
        
        plot_df$Direction <- ifelse(
          plot_df$Significance_Status == "Significant",
          ifelse(plot_df$estimate > 0, "Upregulated", "Downregulated"),
          "Non-significant"
        )
        
        # 4. Generate the Volcano Plot
        p <- ggplot(plot_df, aes(x = estimate, y = -log10(Selected_P), color = Direction)) +
          geom_point(alpha = 0.7, size = 2) +
          scale_color_manual(
            values = c(
              "Upregulated" = "#E41A1C",
              "Downregulated" = "#377EB8",
              "Non-significant" = "#999999"
            )
          ) +
          geom_hline(yintercept = -log10(p_threshold), linetype = "dashed", color = "black") +
          theme_minimal() +
          theme(
            legend.position = "top",
            panel.grid.minor = element_blank()
          ) +
          labs(
            title = paste("Volcano Plot (", input$volcano_plot_type, ")", sep=""),
            x = "Estimate (Difference)",
            y = paste("-log10(", if(p_col == "Adjusted_pval") "Adjusted P-value" else "Unadjusted P-value", ")", sep=""),
            color = "Status"
          )

        # 5. Add custom annotations
        if (input$volcano_label_sig) {
          sig_proteins <- plot_df %>%
            filter(Significance_Status == "Significant") %>%
            arrange(Selected_P) %>%
            head(20)
          
          if (nrow(sig_proteins) > 0) {
            p <- p + geom_text_repel(data = sig_proteins, 
                                     aes(label = Assay),
                                     size = 3.5, max.overlaps = 50,
                                     box.padding = 0.5, point.padding = 0.5,
                                     fontface = "bold", show.legend = FALSE)
          }
        }
        
        current_plot(p)
        
        # Log analysis
        log_analysis(analysis_log, "Volcano Plot", 
                     paste("Method:", input$volcano_plot_type, "| P-val Type:", input$volcano_p_val_type, "| P-threshold:", input$volcano_p_threshold),
                     plot = p)
        
      }, error = function(e) {
        showNotification(paste("Error generating volcano plot:", e$message), type = "error")
      })
      incProgress(1)
    })
  })
  
  output$volcano_plot <- renderPlot({
    req(current_plot())
    current_plot()
  })
  
  output$download_volcano <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_VolcanoPlot_", input$volcano_plot_type, "_", format(Sys.Date(), "%Y%m%d"), ".png") 
    },
    content = function(file) {
      req(current_plot())
      ggsave(file, plot = current_plot(), device = "png", width = 10, height = 8, dpi = 300)
    }
  )
}