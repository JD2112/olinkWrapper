library(ggrepel)

volcano_plot_server <- function(input, output, session, merged_data, ttest_results, anova_results) {
  # Reactive value to store the current plot
  current_plot <- reactiveVal(NULL)
  
  # Reactive value to store wilcox results
  wilcox_results <- reactiveVal(NULL)

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
        p_col <- input$volcano_p_val_type # "Adjusted_pval" or "p.value"
        p_threshold <- input$volcano_p_threshold
        
        # 3. Create a clean plotting dataframe
        # We don't want to modify the original results, so we create a copy
        plot_df <- results
        
        # Ensure we have an 'estimate' column
        # For Wilcoxon tests, we might need to use a different column
        if (!"estimate" %in% colnames(plot_df)) {
           if ("statistic" %in% colnames(plot_df)) {
             plot_df$estimate <- plot_df$statistic
           } else if ("estimate_median_diff" %in% colnames(plot_df)) {
             plot_df$estimate <- plot_df$estimate_median_diff
           } else {
             plot_df$estimate <- 0
           }
        }
        
        # Explicitly pull the selected P-value into a dedicated column for plotting
        plot_df$Selected_P <- plot_df[[p_col]]
        
        # Safety: Floor p-values to avoid log10(0) = Inf
        plot_df$Selected_P <- ifelse(plot_df$Selected_P <= 0, 1e-300, plot_df$Selected_P)
        
        # Define Significance based on the user-selected p-value column and threshold
        plot_df$Significance_Status <- ifelse(plot_df$Selected_P < p_threshold, "Significant", "Non-significant")
        
        # Determine direction for significant proteins
        plot_df$Direction <- ifelse(
          plot_df$Significance_Status == "Significant",
          ifelse(plot_df$estimate > 0, "Upregulated", "Downregulated"),
          "Non-significant"
        )
        
        # 4. Generate the Volcano Plot manually for maximum control
        # olink_volcano_plot has limitations with custom p-values, so we'll build it with ggplot
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

        # 5. Add custom annotations if requested
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
      paste("volcano_plot_", input$volcano_plot_type, "_", Sys.Date(), ".png", sep="") 
    },
    content = function(file) {
      req(current_plot())
      ggsave(file, plot = current_plot(), device = "png", width = 10, height = 8, dpi = 300)
    }
  )
  
  # Return a list containing the wilcox_results setter
  return(list(
    set_wilcox_results = wilcox_results
  ))
}