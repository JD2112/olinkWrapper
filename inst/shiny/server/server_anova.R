anova_server <- function(input, output, session, merged_data, anova_results, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Reactive value to store covariate data
  covariate_data <- reactiveVal(list())
  
  # Update anova_var choices when data is loaded
  observe({
    req(merged_data())
    updateSelectInput(session, "anova_var", choices = colnames(merged_data()))
  })
  
  output$anova_covariate_inputs <- renderUI({
    req(input$anova_num_covariates)
    num <- as.numeric(input$anova_num_covariates)
    
    lapply(seq_len(num), function(i) {
      tagList(
        selectInput(paste0("anova_covariate", i), paste("Select Covariate", i), 
                    choices = c("None", colnames(merged_data()))),
        radioButtons(paste0("anova_covariate_type", i), paste("Covariate", i, "Type"),
                     choices = c("Character", "Factor", "Numeric"))
      )
    })
  })
  
  # Observer to update covariate_data when inputs change
  observe({
    req(input$anova_num_covariates)
    num <- as.numeric(input$anova_num_covariates)
    new_covariate_data <- lapply(seq_len(num), function(i) {
      list(
        name = input[[paste0("anova_covariate", i)]] %||% "None",
        type = input[[paste0("anova_covariate_type", i)]] %||% "Character"
      )
    })
    covariate_data(new_covariate_data)
  })
  
  observeEvent(input$run_anova, {
    withProgress(message = 'Running ANOVA...', value = 0, {
      req(merged_data(), input$anova_var)
      
      tryCatch({
        data_for_test <- merged_data()
        
        incProgress(0.1, detail = "Preparing variables")
        
        # Helper function to check factor levels
        check_levels <- function(vec, name) {
          lvls <- length(unique(na.omit(vec)))
          if (lvls < 2) {
            stop(paste0("Variable '", name, "' has only ", lvls, " level(s). ANOVA requires at least 2 distinct levels."))
          }
        }
        
        # Process main ANOVA variable
        var_name <- input$anova_var
        data_for_test[[var_name]] <- switch(input$anova_var_type,
          "Factor" = as.factor(data_for_test[[var_name]]),
          "Numeric" = as.numeric(data_for_test[[var_name]]),
          as.character(data_for_test[[var_name]])
        )
        
        if (input$anova_var_type %in% c("Factor", "Character")) {
          check_levels(data_for_test[[var_name]], var_name)
        }
        
        covariates <- c()
        covariate_types <- c()
        num <- as.numeric(input$anova_num_covariates)
        
        for(i in seq_len(num)) {
          cov_name <- input[[paste0("anova_covariate", i)]]
          cov_type <- input[[paste0("anova_covariate_type", i)]]
          
          if(!is.null(cov_name) && cov_name != "None") {
            covariates <- c(covariates, cov_name)
            covariate_types <- c(covariate_types, cov_type)
            
            # Process covariate
            data_for_test[[cov_name]] <- switch(cov_type,
              "Factor" = as.factor(data_for_test[[cov_name]]),
              "Numeric" = as.numeric(data_for_test[[cov_name]]),
              as.character(data_for_test[[cov_name]])
            )
            
            if (cov_type %in% c("Factor", "Character")) {
              check_levels(data_for_test[[cov_name]], cov_name)
            }
          }
        }
        
        # Explicit data cleaning to prevent ANOVA crashes
        clean_cols <- c(var_name, covariates)
        data_for_test <- data_for_test %>%
          filter(if_all(all_of(clean_cols), ~ !is.na(.)))
        
        if (nrow(data_for_test) == 0) {
          stop("No samples left after removing missing values in the selected variables/covariates.")
        }
        
        incProgress(0.4, detail = "Calculating ANOVA")
        
        if(length(covariates) == 0) {
          results <- olink_anova(data_for_test, variable = var_name)
        } else {
          results <- tryCatch({
            olink_anova(data_for_test, variable = var_name, covariates = covariates)
          }, error = function(e_inner) {
            if(grepl("singular", e_inner$message)) {
              stop("Linear model system is singular. This often happens with collinear covariates (e.g. gender and another variable are identical).")
            }
            stop(paste("OlinkAnalyze error:", e_inner$message))
          })
        }
        
        if (is.null(results) || nrow(results) == 0) {
          stop("ANOVA produced no results. Check if your groups have sufficient data points and multiple levels.")
        }
        
        incProgress(0.3, detail = "Storing results")
        
        anova_results(list(
          results = results,
          model_details = list(
            variable = var_name,
            variable_type = input$anova_var_type,
            covariates = covariates,
            covariate_types = covariate_types
          )
        ))
        
        # Log analysis
        log_analysis(analysis_log, "ANOVA", 
                     paste("Variable:", var_name, "| Covariates:", paste(covariates, collapse=", ")),
                     table = results)
        
        output$anova_output <- renderDT({
          datatable(results, 
                   extensions = 'Buttons',
                   options = list(
                     scrollX = TRUE,
                     dom = 'Bflrtip',
                     buttons = list(
                       list(extend = "excel", text = "Download current page", 
                            filename = paste0("olinkWrapper_", VERSION, "_ANOVA_", input$anova_var, "_", format(Sys.Date(), "%Y%m%d")),
                            exportOptions = list(modifier = list(page = "current")))
                     )
                   ))
        })
        
        incProgress(0.2, detail = "Done")
      }, error = function(e) {
        showNotification(paste("Error in ANOVA:", e$message), type = "error")
      })
    })
  })
  
  output$download_anova <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_ANOVA_", input$anova_var, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx") 
    },
    content = function(file) {
      req(anova_results())
      writexl::write_xlsx(list(anova_results = anova_results()$results), file)
    }
  )
}