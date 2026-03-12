anova_posthoc_server <- function(input, output, session, merged_data, anova_results, analysis_log) {
  # App Version
  VERSION <- APP_VERSION # Set globally by version.R

  posthoc_results <- reactiveVal(NULL)
  significant_assays <- reactiveVal(NULL)

  # ── Update UI choices from ANOVA results ─────────────────────────
  observe({
    req(anova_results())
    # Populate effect dropdown with terms from the ANOVA results
    terms <- unique(anova_results()$results$term)
    updateSelectInput(session, "posthoc_effect", choices = c("", terms))

    # Populate outcome dropdown (numeric columns from the data)
    req(merged_data())
    numeric_cols <- names(merged_data())[sapply(merged_data(), is.numeric)]
    # Ensure NPX is first
    numeric_cols <- unique(c("NPX", numeric_cols))
    updateSelectInput(session, "posthoc_outcome", choices = numeric_cols, selected = "NPX")
  })

  # ── Calculate significant assays when effect changes ─────────────
  observeEvent(input$posthoc_effect, {
    req(anova_results(), input$posthoc_effect, input$posthoc_effect != "")
    sig_assays <- anova_results()$results %>%
      filter(Threshold == "Significant" & term == input$posthoc_effect) %>%
      select(OlinkID) %>%
      distinct() %>%
      pull()
    significant_assays(sig_assays)

    # Show summary text
    output$posthoc_summary <- renderPrint({
      cat("ANOVA model summary (inherited):\n")
      cat("  Variable:", anova_results()$model_details$variable, "\n")
      covs <- anova_results()$model_details$covariates
      if (length(covs) > 0) {
        cat("  Covariates:", paste(covs, collapse = ", "), "\n")
      } else {
        cat("  Covariates: (none)\n")
      }
      cat("  Selected effect:", input$posthoc_effect, "\n")
      cat("  Significant assays for this effect:", length(sig_assays), "\n")
    })
  })

  # ── Run Post-hoc ─────────────────────────────────────────────────
  observeEvent(input$run_anova_posthoc, {
    withProgress(message = "Running ANOVA Post-hoc Analysis...", value = 0, {
      tryCatch(
        {
          req(merged_data(), anova_results(), input$posthoc_effect, input$posthoc_effect != "")

          # ── 1. Prepare data ──────────────────────────────
          data_for_analysis <- merged_data()

          # Get ANOVA model details (variable + covariates)
          anova_model <- anova_results()$model_details
          if (is.null(anova_model)) {
            stop("ANOVA model details not found. Please run ANOVA first.")
          }
          variable <- anova_model$variable
          covariates <- anova_model$covariates

          # Convert character columns to factors for `olink_anova_posthoc`
          all_model_vars <- c(variable, covariates)
          for (v in all_model_vars) {
            if (!is.null(v) && v %in% colnames(data_for_analysis)) {
              if (is.character(data_for_analysis[[v]])) {
                data_for_analysis[[v]] <- as.factor(data_for_analysis[[v]])
              }
            }
          }

          # NULL-safe covariates (olink_anova_posthoc expects NULL, not c())
          if (length(covariates) == 0) covariates <- NULL

          # ── 2. Determine effect ──────────────────────────
          effect <- input$posthoc_effect

          # ── 3. Determine outcome ─────────────────────────
          outcome <- input$posthoc_outcome
          if (is.null(outcome) || outcome == "") outcome <- "NPX"

          # ── 4. Determine OlinkID list ────────────────────
          custom_list <- trimws(input$posthoc_olinkid_list)

          if (!is.null(custom_list) && custom_list != "") {
            # User provided explicit OlinkIDs
            olinkid_list <- trimws(strsplit(custom_list, ",")[[1]])
          } else if (input$use_significant_only) {
            olinkid_list <- significant_assays()
            if (is.null(olinkid_list) || length(olinkid_list) == 0) {
              showNotification(
                paste0(
                  "No significant assays found for effect '", effect,
                  "'. Uncheck 'Significant Assays Only' or choose a different effect."
                ),
                type = "warning"
              )
              return(NULL)
            }
          } else {
            # Use all OlinkIDs
            olinkid_list <- unique(data_for_analysis$OlinkID)
          }

          incProgress(0.3, detail = "Computing post-hoc comparisons...")

          # ── 5. Call olink_anova_posthoc ───────────────────
          output_capture <- capture.output({
            results <- olink_anova_posthoc(
              df = data_for_analysis,
              olinkid_list = olinkid_list,
              variable = variable,
              covariates = covariates,
              outcome = outcome,
              effect = effect,
              mean_return = input$posthoc_mean_return,
              post_hoc_padjust_method = input$posthoc_padjust_method,
              verbose = input$posthoc_verbose
            )
          })

          if (is.null(results) || nrow(results) == 0) {
            showNotification(
              "No post-hoc results produced. Ensure the effect variable has >1 group level in the data.",
              type = "warning"
            )
            return(NULL)
          }

          incProgress(0.5, detail = "Formatting results...")

          # ── 6. Store results ─────────────────────────────
          posthoc_results(results)

          # Log analysis
          log_analysis(analysis_log, "ANOVA Post-hoc",
            paste(
              "Effect:", effect,
              "| Outcome:", outcome,
              "| Padjust:", input$posthoc_padjust_method,
              "| Assays:", length(olinkid_list),
              "| MeanReturn:", input$posthoc_mean_return
            ),
            table = results
          )

          # ── 7. Render table ──────────────────────────────
          output$anova_posthoc_output <- renderDT({
            datatable(results,
              extensions = c("Buttons"),
              options = list(
                scrollX = TRUE,
                dom = "Bflrtip",
                pageLength = 15,
                buttons = list(
                  list(
                    extend = "excel",
                    text = "Download current page",
                    filename = paste0("olinkWrapper_", VERSION, "_ANOVA_PostHoc_", effect, "_", format(Sys.Date(), "%Y%m%d")),
                    exportOptions = list(modifier = list(page = "current"))
                  )
                )
              )
            )
          })

          incProgress(0.2)
          showNotification(
            paste("Post-hoc completed:", nrow(results), "comparisons for", length(unique(results$OlinkID)), "assays."),
            type = "message"
          )
        },
        error = function(e) {
          msg <- e$message
          # Friendly error messages for common failures
          if (grepl("length of zero|length zero", msg, ignore.case = TRUE)) {
            msg <- paste0(
              "Internal contrast calculation failed (argument of length zero). ",
              "This can happen when the effect variable '", input$posthoc_effect,
              "' has insufficient factor levels after NA removal. ",
              "Try unchecking 'Significant Assays Only' or check your data for missing values."
            )
          }
          if (grepl("singular", msg, ignore.case = TRUE)) {
            msg <- "Model is singular. This often happens with collinear covariates. Try removing one."
          }
          showNotification(paste("Error in ANOVA Post-hoc:", msg), type = "error")
          print(paste("ANOVA Post-hoc Error Detail:", e$message))
        }
      )
    })
  })

  # ── Download handler ──────────────────────────────────────────────
  output$download_anova_posthoc <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_ANOVA_PostHoc_", input$posthoc_effect, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
    },
    content = function(file) {
      req(posthoc_results())
      writexl::write_xlsx(list(anova_posthoc_results = posthoc_results()), file)
    }
  )
}
