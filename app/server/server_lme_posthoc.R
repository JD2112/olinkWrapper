lme_posthoc_server <- function(input, output, session, merged_data, lme_results) {
  
  posthoc_results <- reactiveVal(NULL)
  significant_assays <- reactiveVal(NULL)
  formula_used <- reactiveVal(NULL)
  
  observe({
    req(lme_results())
      
      # Update choices for lme_posthoc_variable and lme_posthoc_random based on the merged_data
      updateSelectInput(session, "lme_posthoc_variable", choices = names(merged_data()))
      updateSelectInput(session, "lme_posthoc_random", choices = names(merged_data()))
      
      # Update choices for lme_posthoc_effect based on the terms in LME results
      if("results" %in% names(lme_results()) && "term" %in% names(lme_results()$results)) {
        terms <- unique(lme_results()$results$term)
        updateSelectInput(session, "lme_posthoc_effect", choices = c("", terms))
      } else {
        print("lme_results does not have the expected structure")
      }
    
  })
  
  # Calculate significant assays when lme_posthoc_effect changes
  observeEvent(input$lme_posthoc_effect, {
    req(lme_results(), input$lme_posthoc_effect)
    sig_assays <- lme_results()$results %>%
      filter(Threshold == 'Significant' & term == input$lme_posthoc_effect) %>%
      select(OlinkID) %>%
      distinct() %>%
      pull()
    significant_assays(sig_assays)
  })
  
  observeEvent(input$run_lme_posthoc, {
    withProgress(message = 'Running LME Post-hoc Analysis...', value = 0, {
      tryCatch({
        req(merged_data(), lme_results(), input$lme_posthoc_variable, input$lme_posthoc_random, input$lme_posthoc_effect)
        
        # Prepare data and parameters
        data_for_analysis <- merged_data()
        
        # Determine which Olink IDs to use
        if (input$lme_use_significant_only) {
          olinkid_list <- significant_assays()
        } else if (input$lme_posthoc_olinkid_list != "") {
          olinkid_list <- strsplit(input$lme_posthoc_olinkid_list, ",")[[1]]
        } else {
          olinkid_list <- NULL  # This will use all assays
        }
        
        formula_used(paste("Variables:", paste(input$lme_posthoc_variable, collapse=", "),
                           "\nRandom Effect:", input$lme_posthoc_random,
                           "\nEffect:", input$lme_posthoc_effect))
        
        # Capture the output of olink_lmer_posthoc
        output_capture <- capture.output({
          results <- olink_lmer_posthoc(
            df = data_for_analysis,
            olinkid_list = olinkid_list,
            variable = input$lme_posthoc_variable,
            random = input$lme_posthoc_random,
            effect = input$lme_posthoc_effect,
            post_hoc_padjust_method = input$lme_posthoc_padjust_method
          )
        })
        
        # Update formula_used with additional information
        formula_used(paste(
          formula_used(),
          "\n",
          paste(output_capture[1:3], collapse = "\n")
        ))
        
        # Store the results
        posthoc_results(results)
        
        output$lme_posthoc_output <- renderDT({
          datatable(results, 
            options = list(
              scrollX = TRUE,
              pageLength = 10,
              lengthMenu = c(10, 25, 50, 100)
            )
          )
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in LME Post-hoc Analysis:", e$message), type = "error")
      })
    })
  })
  
  # Download handler for post-hoc results
  output$download_lme_posthoc <- downloadHandler(
    filename = function() {
      paste("lme_posthoc_results_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      req(posthoc_results())
      write_xlsx(list(lme_posthoc_results = posthoc_results()), file)
    }
  )
  
  # Return reactive values that might be needed elsewhere
  return(list(
    posthoc_results = posthoc_results,
    formula_used = formula_used
  ))
}