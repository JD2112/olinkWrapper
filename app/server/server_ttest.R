ttest_server <- function(input, output, session, merged_data, ttest_results) {
  
  # Update grouping variable choices when data is loaded
  observe({
    req(merged_data())
    vars <- colnames(merged_data())
    # Filter for columns that might be grouping variables (not too many unique values)
    # But for now, let's just provide all columns.
    updateSelectInput(session, "ttest_var", choices = vars)
  })

  observeEvent(input$run_ttest, {
    print("T-test button clicked")
    withProgress(message = 'Running T-Test...', value = 0, {
      tryCatch({
        req(merged_data(), input$ttest_var)
        data_for_test <- merged_data()
        
        # Check if the grouping variable exists and has exactly 2 levels
        group_vals <- data_for_test[[input$ttest_var]]
        unique_vals <- unique(group_vals[!is.na(group_vals)])
        
        if (length(unique_vals) != 2) {
          stop(paste("Grouping variable", input$ttest_var, "must have exactly 2 levels. Found:", paste(unique_vals, collapse = ", ")))
        }

        if (input$ttest_var_type == "Factor") {
          data_for_test[[input$ttest_var]] <- as.factor(data_for_test[[input$ttest_var]])
        } else {
          data_for_test[[input$ttest_var]] <- as.character(data_for_test[[input$ttest_var]])
        } 
        
        print("Running olink_ttest function")
        results <- olink_ttest(data_for_test, variable = input$ttest_var)
        
        if (nrow(results) == 0) {
          stop("T-test returned no results. Check if data is properly normalized and group sizes are sufficient.")
        }

        ttest_results(results)  # Store results in reactive value
        
        output$ttest_output <- renderDT({
          datatable(results, 
            options = list(
                         paging = TRUE,
                         searching = TRUE,
                         fixedColumns = TRUE,
                         autowidth = TRUE,
                         ordering = TRUE,
                         dom = 'Bflrtip',
                         lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100','All')),
                         scrollX = TRUE,
                         buttons = list(
                           list(extend = "excel", text = "Download current page", 
                                filename = "T-test Analysis",
                                exportOptions = list(
                                  modifier = list(page = "current")
                                ))))
                                )
        })
        
        incProgress(1)
        showNotification("T-test completed successfully", type = "message")
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