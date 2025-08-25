lme_stats_server <- function(input, output, session, merged_data, lme_results) {
  
  # Update UI choices based on available data
  observe({
    req(merged_data())
    # updateSelectInput(session, "mw_variable", choices = names(merged_data()))
    # updateSelectInput(session, "mw_group1", choices = unique(merged_data()$Group))
    # updateSelectInput(session, "mw_group2", choices = unique(merged_data()$Group))
    updateSelectInput(session, "lmer_outcome", choices = names(merged_data()))
    updateSelectInput(session, "lmer_fixed", choices = names(merged_data()))
    updateSelectInput(session, "lmer_random", choices = names(merged_data()))
    # updateSelectInput(session, "nonparam_variable", choices = names(merged_data()))
    # updateSelectInput(session, "nonparam_group", choices = names(merged_data()))
  })
  
  # # Mann-Whitney U Test
  # observeEvent(input$run_mw_test, {
  #   req(merged_data(), input$mw_variable, input$mw_group1, input$mw_group2)
    
  #   withProgress(message = 'Running Mann-Whitney U Test...', value = 0, {
  #     tryCatch({
  #       results <- olink_wilcox(merged_data(), 
  #                               variable = input$mw_variable,
  #                               alternative = c(input$mw_group1, input$mw_group2))
  #       output$mw_results <- renderPrint({
  #         print(results)
  #       })
  #       incProgress(1)
  #     }, error = function(e) {
  #       showNotification(paste("Error in Mann-Whitney U Test:", e$message), type = "error")
  #     })
  #   })
  # })
  
  # Linear Mixed Effects Model
  observeEvent(input$run_lmer, {
    req(merged_data(), input$lmer_outcome, input$lmer_fixed, input$lmer_random)
    
    withProgress(message = 'Running Linear Mixed Effects Model...', value = 0, {
      tryCatch({
        data_for_lme <- merged_data()
        
        # Convert selected fixed effects to factors
        for (var in input$lmer_fixed) {
          data_for_lme[[var]] <- as.factor(data_for_lme[[var]])
        }
        
        # Convert selected random effects to factors
        for (var in input$lmer_random) {
          data_for_lme[[var]] <- as.factor(data_for_lme[[var]])
        }

        formula <- as.formula(paste(input$lmer_outcome, "~", 
                                    paste(input$lmer_fixed, collapse = " + "), 
                                    "+ (1|", paste(input$lmer_random, collapse = ") + (1|"), ")"))
        results <- olink_lmer(data_for_lme, model_formula = formula)

        output$lmer_results <- renderPrint({
          #print(formula)
          cat(paste0(deparse(formula, width.cutoff = 500), collapse = ""), "\n\n")
        })

        # Store results and model details in reactive value
        lme_results(list(
          results = results,
          model_details = list(
            variable = input$lmer_outcome,  # Assuming this is your outcome variable
            fixed = input$lmer_fixed,       # Your fixed effects
            random = input$lmer_random      # Your random effects
          )
        ))

        # Render the NPX datatable
        output$lme_npx_table <- renderDT({
          #req(lme_results())
          print("Rendering LME NPX table")
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
            filename = "Merged data (current page)",
            exportOptions = list(
              modifier = list(page = "current")
            )
          )
        )
      ))
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in Linear Mixed Effects Model:", e$message), type = "error")
      })
    })
  })
  
  # Non-parametric Tests
  # observeEvent(input$run_nonparam_test, {
  #   req(merged_data(), input$nonparam_test, input$nonparam_variable, input$nonparam_group)
    
  #   withProgress(message = 'Running Non-parametric Test...', value = 0, {
  #     tryCatch({
  #       results <- olink_one_non_parametric(merged_data(), 
  #                                           variable = input$nonparam_variable,
  #                                           group = input$nonparam_group,
  #                                           test = input$nonparam_test)
  #       output$nonparam_results <- renderPrint({
  #         print(results)
  #       })
  #       incProgress(1)
  #     }, error = function(e) {
  #       showNotification(paste("Error in Non-parametric Test:", e$message), type = "error")
  #     })
  #   })
  # })
}