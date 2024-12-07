ttest_server <- function(input, output, session, merged_data, ttest_results) {
  observeEvent(input$run_ttest, {
    withProgress(message = 'Running T-Test...', value = 0, {
      tryCatch({
        req(merged_data(), input$ttest_var)
        data_for_test <- merged_data()
        
        if (input$ttest_var_type == "Factor") {
          data_for_test[[input$ttest_var]] <- as.factor(data_for_test[[input$ttest_var]])
        } else {
          data_for_test[[input$ttest_var]] <- as.character(data_for_test[[input$ttest_var]])
        }
        
        results <- olink_ttest(data_for_test, variable = input$ttest_var)
        ttest_results(results)  # Store results in reactive value
        
        output$ttest_output <- renderDT({
          datatable(results, options = list(scrollX = TRUE))
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in T-Test:", e$message), type = "error")
      })
    })
  })
  
  output$download_ttest <- downloadHandler(
    filename = function() { paste("ttest_results_", Sys.Date(), ".xlsx", sep="") },
    content = function(file) {
      req(ttest_results())
      write_xlsx(list(ttest_results = ttest_results()), file)
    }
  )
}