lme_server <- function(input, output, session, merged_data) {
  
  print("LME server function called")
  
  # Update UI choices based on available data
  observe({
    print("LME: Observe block triggered")
    if(is.null(merged_data())) {
      print("LME: merged_data is NULL")
    } else {
      choices <- names(merged_data())
      print(paste("LME: Available choices:", paste(choices, collapse = ", ")))
      updateSelectInput(session, "lme_outcome_var", choices = choices)
      updateSelectInput(session, "lme_fixed_effects", choices = choices)
      updateSelectInput(session, "lme_random_effects", choices = choices)
    }
  })

  # Linear Mixed Effects Model
  observeEvent(input$run_lme_model, {
    print("LME: Run model button clicked")
    req(merged_data(), input$lme_outcome_var, input$lme_fixed_effects, input$lme_random_effects)
    
    withProgress(message = 'Running Linear Mixed Effects Model...', value = 0, {
      tryCatch({
        data_for_lme <- merged_data()
        
        # Convert all fixed and random effects to factors
        for (var in c(input$lme_fixed_effects, input$lme_random_effects)) {
          if (!is.numeric(data_for_lme[[var]])) {
            data_for_lme[[var]] <- as.factor(data_for_lme[[var]])
          }
        }

        formula <- as.formula(paste(input$lme_outcome_var, "~", 
                                    paste(input$lme_fixed_effects, collapse = " + "), 
                                    "+ (1|", paste(input$lme_random_effects, collapse = ") + (1|"), ")"))
        
        print(paste("LME: Formula -", deparse(formula)))
        
        results <- olink_lmer(data_for_lme, model_formula = formula)
        
        output$lme_model_results <- renderPrint({
          print("LME: Model formula")
          print(formula)
          print("LME: Model summary")
          print(summary(results))
        })

        # Render the results datatable
        output$lme_results_table <- renderDT({
          req(results)
          print("LME: Rendering results table")
          datatable(results, 
                    extensions = c('Buttons'),
                    options = list(
                      paging = TRUE,
                      searching = TRUE,
                      fixedColumns = TRUE,
                      autowidth = TRUE,
                      ordering = TRUE,
                      dom = 'Bflrtip',
                      lengthMenu = list(c(10, 25, 50, 100, 1000, -1), 
                                        c('10', '25', '50', '100','1000', 'All')),
                      scrollX = TRUE,
                      buttons = list(
                        list(
                          extend = "excel", 
                          text = "Download current page", 
                          filename = "LME results (current page)",
                          exportOptions = list(
                            modifier = list(page = "current")
                          )
                        )
                      )
                    ))
        })
        
        incProgress(1)
      }, error = function(e) {
        print(paste("LME: Error -", e$message))
        showNotification(paste("Error in Linear Mixed Effects Model:", e$message), type = "error")
      })
    })
  })
}