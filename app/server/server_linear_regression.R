linear_regression_server <- function(input, output, session, merged_data, analysis_log) {

  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  regression_results_rv <- reactiveVal(NULL)

  # Dependent variable UI
  output$dependent_var_ui <- renderUI({
    req(merged_data())
    numeric_cols <- names(merged_data())[sapply(merged_data(), is.numeric)]
    selectInput("dependent_var", "Select Dependent Variable", choices = numeric_cols)
  })

  # Covariate UI
  output$linreg_covariate_inputs <- renderUI({
    req(input$linreg_num_covariates)
    num <- as.numeric(input$linreg_num_covariates)
    lapply(seq_len(num), function(i) {
      tagList(
        selectInput(paste0("linreg_covariate", i), paste("Select Covariate", i),
                    choices = colnames(merged_data()), selected = "None"),
        radioButtons(paste0("linreg_cov_type", i), paste("Covariate", i, "Type"),
                     choices = c("Character", "Factor", "Numeric"), inline = TRUE)
      )
    })
  })

  # Update covariate selectInput choices when merged_data or num_covariates changes
  observe({
    req(merged_data())
    cols <- colnames(merged_data())
    num_covs <- as.numeric(input$linreg_num_covariates %||% 0)
    for (i in seq_len(num_covs)) {
      updateSelectInput(session, paste0("linreg_covariate", i), choices = c("None", cols))
    }
  })

  # Perform linear regression when button clicked
  observeEvent(input$run_regression, {
    withProgress(message = 'Running Linear Regression...', value = 0, {
      tryCatch({
        req(merged_data())
        df <- merged_data()
        dep_var <- input$dependent_var
        
        # Collect covariates
        covariates <- unlist(lapply(seq_len(input$linreg_num_covariates), function(i) input[[paste0("linreg_covariate", i)]]))
        covariates <- covariates[!is.na(covariates) & covariates != "" & covariates != "None"]

        # Preprocess covariate types
        for (i in seq_along(covariates)) {
          cov <- covariates[i]
          cov_type <- input[[paste0("linreg_cov_type", i)]]
          if (!is.null(cov_type)) {
            df[[cov]] <- switch(cov_type,
                                "Character" = as.character(df[[cov]]),
                                "Factor" = as.factor(df[[cov]]),
                                "Numeric" = as.numeric(df[[cov]]),
                                df[[cov]])
          }
        }

        # NPX scaling
        npx_var <- if (input$npx_or_zscore == "Z-score") {
          df <- df %>% group_by(Assay) %>% mutate(NPX_scaled = scale(NPX)[,1]) %>% ungroup()
          "NPX_scaled"
        } else {
          "NPX"
        }

        assays <- unique(df$Assay)
        
        results <- purrr::map_dfr(assays, function(assay) {
          assay_data <- df %>% filter(Assay == assay)
          safe_dep_var <- paste0("`", dep_var, "`")
          safe_npx <- paste0("`", npx_var, "`")
          
          formula_str <- if (length(covariates) > 0) {
            paste(safe_dep_var, "~", safe_npx, "+", paste0("`", covariates, "`", collapse = " + "))
          } else {
            paste(safe_dep_var, "~", safe_npx)
          }
          
          model <- tryCatch(lm(as.formula(formula_str), data = assay_data), error = function(e) NULL)
          if (is.null(model)) return(NULL)

          broom::tidy(model, conf.int = TRUE) %>%
            filter(term == npx_var) %>%
            mutate(Assay = assay) %>%
            left_join(distinct(assay_data, Assay, OlinkID, UniProt, Panel), by = "Assay")
        })

        if (nrow(results) > 0) {
          results_clean <- results %>%
            mutate(Adjusted_pval = p.adjust(p.value, method = "BH")) %>%
            select(Assay, OlinkID, UniProt, Panel, estimate, conf.low, conf.high, 
                   statistic, p.value, Adjusted_pval) %>%
            arrange(p.value)

          regression_results_rv(results_clean)

          # Log analysis
          log_analysis(analysis_log, "Linear Regression", 
                       paste("Dep Var:", dep_var, "| Covariates:", paste(covariates, collapse=", ")),
                       table = results_clean)

          output$regression_results <- DT::renderDataTable({
            DT::datatable(results_clean, 
                         extensions = 'Buttons',
                         options = list(
                           pageLength = 15,
                           scrollX = TRUE,
                           dom = 'Bflrtip',
                           buttons = list(
                             list(extend = "excel", text = "Download current page", 
                                  filename = paste0("olinkWrapper_", VERSION, "_LinearRegression_", dep_var, "_", format(Sys.Date(), "%Y%m%d")),
                                  exportOptions = list(modifier = list(page = "current")))
                           )
                         ), 
                         rownames = FALSE) %>%
              DT::formatRound(c("estimate", "conf.low", "conf.high", "statistic", 
                                "p.value", "Adjusted_pval"), 8)
          })
          
          showNotification(paste("Regression completed."), type = "message")
        }
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in Linear Regression:", e$message), type = "error")
      })
    })
  })

  # Download handler
  output$download_regression <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_LinearRegression_Results_", input$dependent_var, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
    },
    content = function(file) {
      req(regression_results_rv())
      writexl::write_xlsx(list(linear_regression_results = regression_results_rv()), file)
    }
  )
}