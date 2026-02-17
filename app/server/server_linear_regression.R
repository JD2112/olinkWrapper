linear_regression_server <- function(input, output, session, merged_data) {

  regression_results_rv <- reactiveVal(NULL)

  # Dependent variable UI
  output$dependent_var_ui <- renderUI({
    req(merged_data())
    numeric_cols <- names(merged_data())[sapply(merged_data(), is.numeric)]
    selectInput("dependent_var", "Select Dependent Variable", choices = numeric_cols)
  })

  # Covariate UI
  output$covariate_inputs <- renderUI({
    req(input$num_covariates)
    num <- input$num_covariates
    lapply(seq_len(num), function(i) {
      tagList(
        selectInput(paste0("covariate", i), paste("Select Covariate", i),
                    choices = colnames(merged_data()), selected = NULL),
        radioButtons(paste0("cov_type", i), paste("Covariate", i, "Type"),
                     choices = c("Character", "Factor", "Numeric"), inline = TRUE)
      )
    })
  })

  # Update dependent variable choices based on merged_data
  output$dependent_var_ui <- renderUI({
    req(merged_data())
    numeric_cols <- names(merged_data())[sapply(merged_data(), is.numeric)]
    selectInput("dependent_var", "Select Dependent Variable", choices = numeric_cols)
  })

  # Update covariate selectInput choices when merged_data or num_covariates changes
  observe({
    req(merged_data())
    cols <- colnames(merged_data())

    num_covs <- as.numeric(input$num_covariates %||% 0)
    for (i in seq_len(num_covs)) {
      updateSelectInput(session, paste0("covariate", i), choices = c("None", cols))
    }
  })

  # Perform linear regression when button clicked
  observeEvent(input$run_regression, {
    withProgress(message = 'Running Linear Regression...', value = 0, {
      tryCatch({
        req(merged_data())
        df <- merged_data()

        incProgress(0.1, detail = "Preparing data")

        # Check if Assay column exists
        if (!"Assay" %in% colnames(df)) {
          showNotification("'Assay' column not found in dataset. Cannot run regression.", type = "error")
          return(NULL)
        }

        # Get dependent variable
        dep_var <- input$dependent_var
        if (is.null(dep_var) || dep_var == "") {
          showNotification("Please select a dependent variable.", type = "error")
          return(NULL)
        }

        # Collect covariates selected by user
        covariates <- unlist(lapply(seq_len(input$num_covariates), function(i) input[[paste0("covariate", i)]]))
        covariates <- covariates[!is.na(covariates) & covariates != "" & covariates != "None"]

        incProgress(0.2, detail = "Preprocessing covariates")

        # Preprocess covariate types (Character/Factor/Numeric)
        for (i in seq_along(covariates)) {
          cov <- covariates[i]
          cov_type <- input[[paste0("cov_type", i)]]
          if (!is.null(cov_type)) {
            df[[cov]] <- switch(cov_type,
                                "Character" = as.character(df[[cov]]),
                                "Factor" = as.factor(df[[cov]]),
                                "Numeric" = as.numeric(df[[cov]]),
                                df[[cov]]) # default to original if no match
          }
        }

        incProgress(0.3, detail = "Processing NPX values")

        # Standardize NPX to Z-score if selected
        if (input$npx_or_zscore == "Z-score") {
          df <- df %>%
            group_by(Assay) %>%
            mutate(NPX_scaled = scale(NPX)[,1]) %>%
            ungroup()
          npx_var <- "NPX_scaled"
        } else {
          npx_var <- "NPX"
        }

        # Get unique assays (proteins)
        assays <- unique(df$Assay)
        
        incProgress(0.5, detail = "Fitting models")

        # Run linear regression for each Assay (protein)
        # Model: DependentVariable ~ NPX + Covariates
        results <- purrr::map_dfr(assays, function(assay) {
          # Filter data for this specific assay
          assay_data <- df %>% filter(Assay == assay)
          
          # Build formula: DependentVariable ~ NPX + covariate1 + covariate2 + ...
          safe_dep_var <- paste0("`", dep_var, "`")
          safe_npx <- paste0("`", npx_var, "`")
          
          if (length(covariates) > 0) {
            safe_covariates <- paste0("`", covariates, "`", collapse = " + ")
            formula_str <- paste(safe_dep_var, "~", safe_npx, "+", safe_covariates)
          } else {
            formula_str <- paste(safe_dep_var, "~", safe_npx)
          }
          
          form <- as.formula(formula_str)

          model <- tryCatch(lm(form, data = assay_data), error = function(e) NULL)
          if (is.null(model)) return(NULL)

          # Extract results - get the NPX coefficient
          model_summary <- broom::tidy(model, conf.int = TRUE) %>%
            filter(term == npx_var) %>%
            mutate(Assay = assay)
          
          # Add Olink metadata if available
          if ("OlinkID" %in% colnames(assay_data)) {
            model_summary$OlinkID <- unique(assay_data$OlinkID)[1]
          }
          if ("UniProt" %in% colnames(assay_data)) {
            model_summary$UniProt <- unique(assay_data$UniProt)[1]
          }
          if ("Panel" %in% colnames(assay_data)) {
            model_summary$Panel <- unique(assay_data$Panel)[1]
          }
          
          return(model_summary)
        })

        incProgress(0.9, detail = "Processing results")

        if (nrow(results) > 0) {
          results_clean <- results %>%
            mutate(Adjusted_pval = p.adjust(p.value, method = "BH")) %>%
            select(Assay, OlinkID, UniProt, Panel, estimate, conf.low, conf.high, 
                   statistic, p.value, Adjusted_pval) %>%
            arrange(p.value)

          regression_results_rv(results_clean)

          output$regression_results <- DT::renderDataTable({
            DT::datatable(results_clean, 
                         options = list(
                           pageLength = 15,
                           scrollX = TRUE
                         ), 
                         rownames = FALSE) %>%
              DT::formatRound(c("estimate", "conf.low", "conf.high", "statistic", 
                               "p.value", "Adjusted_pval"), 8)
          })
          
          showNotification(
            paste("Regression completed for", length(assays), "proteins."), 
            type = "message"
          )
        } else {
          regression_results_rv(NULL)
          output$regression_results <- DT::renderDataTable({
            DT::datatable(data.frame(Message = "No valid models or significant results."), rownames = FALSE)
          })
        }

        incProgress(1, detail = "Done")
      }, error = function(e) {
        print(paste("Error in Linear Regression:", e$message))
        showNotification(paste("Error in Linear Regression:", e$message), type = "error")
      })
    })
  })

  # Download handler for regression results CSV
  output$download_regression <- downloadHandler(
    filename = function() {
      paste0("linear_regression_results_", Sys.Date(), ".csv")
    },
    content = function(file) {
      results <- regression_results_rv()
      if (!is.null(results)) {
        readr::write_csv(results, file)
      }
    }
  )

  # Observer to print regression results reactive structure (for debugging)
  observe({
    print("Checking regression_results_rv():")
    print(str(regression_results_rv()))
  })
}