anova_server <- function(input, output, session, merged_data, anova_results) {
  output$covariate_inputs <- renderUI({
    req(input$num_covariates)
    num_covariates <- as.numeric(input$num_covariates)
    lapply(1:num_covariates, function(i) {
      selectInput(paste0("covariate", i), paste("Select Covariate", i), 
                  choices = c("None", colnames(merged_data())))
    })
  })
  
  observeEvent(input$run_anova, {
    withProgress(message = 'Running ANOVA...', value = 0, {
      req(merged_data(), input$anova_var)
      data_for_test <- merged_data()
      
      if (input$anova_var_type == "Factor") {
        data_for_test[[input$anova_var]] <- as.factor(data_for_test[[input$anova_var]])
      } else {
        data_for_test[[input$anova_var]] <- as.character(data_for_test[[input$anova_var]])
      }
      
      covariates <- c()
      for(i in 1:as.numeric(input$num_covariates)) {
        cov <- input[[paste0("covariate", i)]]
        if(!is.null(cov) && cov != "None") {
          covariates <- c(covariates, cov)
        }
      }
      
      if(length(covariates) == 0) {
        results <- olink_anova(data_for_test, variable = input$anova_var)
      } else {
        results <- olink_anova(data_for_test, variable = input$anova_var, covariates = covariates)
      }
      
      anova_results(results)  # Store results in reactive value
      
      output$anova_output <- renderDT({
        datatable(results, options = list(scrollX = TRUE))
      })
      incProgress(1)
    })
  })
  
  output$download_anova <- downloadHandler(
    filename = function() { paste("anova_results_", Sys.Date(), ".xlsx", sep="") },
    content = function(file) {
      req(anova_results())
      write_xlsx(list(anova_results = anova_results()), file)
    }
  )
}