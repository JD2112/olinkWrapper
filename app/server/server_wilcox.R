wilcox_server <- function(input, output, session, merged_data) {
  
  # Store the results in a reactive value
  wilcox_results <- reactiveVal(NULL)
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    updateSelectInput(session, "mw_variable", choices = names(merged_data()))
  })
  
  # Mann-Whitney U Test
  observeEvent(input$run_mw_test, {    
    withProgress(message = 'Running Mann-Whitney U Test...', value = 0, {
      tryCatch({
        req(merged_data(), input$mw_variable)
        data_for_test <- merged_data()

        # Convert the selected variable to factor or character
        if (input$wilcox_var_type == "Factor") {
          data_for_test[[input$mw_variable]] <- as.factor(data_for_test[[input$mw_variable]])
        } else {
          data_for_test[[input$mw_variable]] <- as.character(data_for_test[[input$mw_variable]])
        }

        results <- olink_wilcox(data_for_test, 
                                variable = input$mw_variable,
                                alternative = input$alternative)
        
        # Store the results
        wilcox_results(results)
        
        output$wilcox_output <- renderDT({
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
                                filename = "Wilcox test Analysis",
                                exportOptions = list(
                                  modifier = list(page = "current")
                                ))))
                                )
        })

        incProgress(1)

      }, error = function(e) {
        showNotification(paste("Error in Mann-Whitney U Test:", e$message), type = "error")
      })
    })
  })
  
  # Download handler for full results
  output$download_wilcox <- downloadHandler(
    filename = function() {
      paste("wilcox_test_results_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      req(wilcox_results())
      write.csv(wilcox_results(), file, row.names = FALSE)
    }
  )
}