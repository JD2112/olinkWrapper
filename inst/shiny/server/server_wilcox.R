wilcox_server <- function(input, output, session, merged_data, wilcox_results_rv = NULL, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

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
        
        wilcox_results(results)
        
        # Also store in the shared reactive value if provided
        if (!is.null(wilcox_results_rv)) {
          wilcox_results_rv(results)
        }
        
        # Log analysis
        log_analysis(analysis_log, "Wilcoxon Rank Sum", 
                     paste("Variable:", input$mw_variable, "| Alternative:", input$alternative),
                     table = results)
        
        output$wilcox_output <- renderDT({
          datatable(results, 
            extensions = 'Buttons',
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
                     filename = paste0("olinkWrapper_", VERSION, "_Wilcox_", input$mw_variable, "_", format(Sys.Date(), "%Y%m%d")),
                     exportOptions = list(modifier = list(page = "current")))
              )
            ))
        })

        showNotification("Mann-Whitney U Test completed.", type = "message")
        incProgress(1)

      }, error = function(e) {
        showNotification(paste("Error in Mann-Whitney U Test:", e$message), type = "error")
      })
    })
  })
  
  # Download handler for full results
  output$download_wilcox <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_Wilcox_results_", input$mw_variable, "_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      req(wilcox_results())
      write.csv(wilcox_results(), file, row.names = FALSE)
    }
  )
}