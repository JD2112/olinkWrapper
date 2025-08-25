anova_posthoc_server <- function(input, output, session, merged_data, anova_results) {
  
  posthoc_results <- reactiveVal(NULL)
  significant_assays <- reactiveVal(NULL)
  formula_used <- reactiveVal(NULL)
  
  observe({
    req(anova_results())
    # Update choices for posthoc_effect based on the terms in ANOVA results
    terms <- unique(anova_results()$results$term)
    updateSelectInput(session, "posthoc_effect", choices = c("", terms))
  })
  
  # Calculate significant assays when posthoc_effect changes
  observeEvent(input$posthoc_effect, {
    req(anova_results(), input$posthoc_effect)
    sig_assays <- anova_results()$results %>%
      filter(Threshold == 'Significant' & term == input$posthoc_effect) %>%
      select(OlinkID) %>%
      distinct() %>%
      pull()
    significant_assays(sig_assays)
  })
  
  observeEvent(input$run_anova_posthoc, {
    withProgress(message = 'Running ANOVA Post-hoc Analysis...', value = 0, {
      tryCatch({
        req(merged_data(), anova_results(), input$posthoc_effect)
        
        # Prepare data and parameters
        data_for_analysis <- merged_data()
        
        # Get ANOVA model details
        anova_model <- anova_results()$model_details
        if (is.null(anova_model)) {
          stop("ANOVA model details not found. Please run ANOVA first.")
        }
        variable <- anova_model$variable
        covariates <- anova_model$covariates
        
        # Determine which Olink IDs to use
        if (input$use_significant_only) {
          olinkid_list <- significant_assays()
        } else if (input$posthoc_olinkid_list != "") {
          olinkid_list <- strsplit(input$posthoc_olinkid_list, ",")[[1]]
        } else {
          olinkid_list <- NULL  # This will use all assays
        }
        
        effect <- input$posthoc_effect
        formula_used(paste("Effect:", effect))
        
        # Capture the output of olink_anova_posthoc
        output_capture <- capture.output({
          results <- olink_anova_posthoc(
            df = data_for_analysis,
            olinkid_list = olinkid_list,
            variable = variable,
            covariates = covariates,
            effect = effect,
            mean_return = input$posthoc_mean_return,
            post_hoc_padjust_method = input$posthoc_padjust_method,
            verbose = input$posthoc_verbose
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
        
        output$anova_posthoc_output <- renderDT({
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
        showNotification(paste("Error in ANOVA Post-hoc Analysis:", e$message), type = "error")
      })
    })
  })
  
#   # Output for displaying the formula used
#   output$posthoc_formula_used <- renderText({
#     req(formula_used())
#     formula_used()
#   })
  
  # Download handler for post-hoc results
  output$download_anova_posthoc <- downloadHandler(
    filename = function() {
      paste("anova_posthoc_results_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      req(posthoc_results())
      write_xlsx(list(anova_posthoc_results = posthoc_results()), file)
    }
  )
}