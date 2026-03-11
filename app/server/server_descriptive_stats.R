descriptive_stats_server <- function(input, output, session, merged_data, analysis_log) {
  observeEvent(input$run_desc_stats, {
    req(merged_data())
    withProgress(message = 'Calculating descriptive statistics...', value = 0, {
      tryCatch({
        # Calculate descriptive stats per Assay
        summary_df <- merged_data() %>%
          group_by(Assay) %>%
          summarise(
            n = n(),
            Mean = mean(NPX, na.rm = TRUE),
            Median = median(NPX, na.rm = TRUE),
            SD = sd(NPX, na.rm = TRUE),
            Min = min(NPX, na.rm = TRUE),
            Max = max(NPX, na.rm = TRUE),
            Missing = sum(is.na(NPX)),
            .groups = 'drop'
          ) %>%
          mutate(across(where(is.numeric), ~round(., 3)))

        # Update display
        output$desc_stats_output <- renderDT({
          datatable(summary_df, 
                   options = list(scrollX = TRUE, pageLength = 10),
                   selection = 'none',
                   filter = 'top')
        })

        # Log analysis
        log_analysis(analysis_log, "Descriptive Stats", 
                    "Global summary statistics computed per assay (Mean, Median, SD, etc.).",
                    table = summary_df)
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error calculating stats:", e$message), type = "error")
      })
    })
  })
}