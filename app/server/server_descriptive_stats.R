descriptive_stats_server <- function(input, output, session, merged_data) {
  observeEvent(input$run_desc_stats, {
    withProgress(message = 'Calculating descriptive statistics...', value = 0, {
      req(merged_data())
      output$desc_stats_output <- renderDT({
        summary_data <- summary(merged_data())
        summary_df <- as.data.frame(do.call(rbind, lapply(summary_data, function(x) as.list(x))))
        datatable(summary_df, options = list(scrollX = TRUE))
      })
      incProgress(1)
    })
  })
}