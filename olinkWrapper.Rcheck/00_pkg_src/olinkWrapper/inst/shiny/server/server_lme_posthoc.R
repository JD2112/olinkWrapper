lme_posthoc_server <- function(input, output, session, merged_data, lme_results, analysis_log) {
  # App Version
  VERSION <- APP_VERSION # Set globally by version.R

  posthoc_results <- reactiveVal(NULL)
  significant_assays <- reactiveVal(NULL)
  formula_used <- reactiveVal(NULL)

  observe({
    req(lme_results())

    updateSelectInput(session, "lme_posthoc_variable", choices = names(merged_data()))
    updateSelectInput(session, "lme_posthoc_random", choices = names(merged_data()))

    if ("results" %in% names(lme_results()) && "term" %in% names(lme_results()$results)) {
      terms <- unique(lme_results()$results$term)
      updateSelectInput(session, "lme_posthoc_effect", choices = c("", terms))
    }
  })

  # Calculate significant assays when lme_posthoc_effect changes
  observeEvent(input$lme_posthoc_effect, {
    req(lme_results(), input$lme_posthoc_effect)
    sig_assays <- lme_results()$results %>%
      filter(Threshold == "Significant" & term == input$lme_posthoc_effect) %>%
      select(OlinkID) %>%
      distinct() %>%
      pull()
    significant_assays(sig_assays)
  })

  observeEvent(input$run_lme_posthoc, {
    withProgress(message = "Running LME Post-hoc Analysis...", value = 0, {
      tryCatch(
        {
          req(merged_data(), lme_results(), input$lme_posthoc_variable, input$lme_posthoc_random, input$lme_posthoc_effect)

          data_for_analysis <- merged_data()

          # Determine which Olink IDs to use
          if (input$lme_use_significant_only) {
            olinkid_list <- significant_assays()
            if (is.null(olinkid_list) || length(olinkid_list) == 0) {
              showNotification("No significant assays found in LME results for the selected effect. Try unchecking 'Significant Assays Only'.", type = "warning")
              return(NULL)
            }
          } else if (input$lme_posthoc_olinkid_list != "") {
            olinkid_list <- strsplit(input$lme_posthoc_olinkid_list, ",")[[1]]
            olinkid_list <- trimws(olinkid_list)
          } else {
            # Use all unique OlinkIDs if nothing specified
            olinkid_list <- unique(data_for_analysis$OlinkID)
          }

          incProgress(0.5, detail = "Calculating post-hoc")

          # Capture output for potential debugging
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

          if (is.null(results) || nrow(results) == 0) {
            showNotification("No results found in LME Post-hoc. Ensure the effect variable and data structure allow for comparisons.", type = "warning")
            return(NULL)
          }

          posthoc_results(results)

          # Log analysis
          log_analysis(analysis_log, "LME Post-hoc",
            paste("Effect:", input$lme_posthoc_effect, "| Padjust Method:", input$lme_posthoc_padjust_method),
            table = results
          )

          output$lme_posthoc_output <- renderDT({
            datatable(results, options = list(scrollX = TRUE, pageLength = 10))
          })

          incProgress(1)
        },
        error = function(e) {
          msg <- e$message
          if (grepl("rank deficient", msg, ignore.case = TRUE) || grepl("singular", msg, ignore.case = TRUE)) {
            msg <- "Error in LME post-hoc: Rank deficiency detected in the model matrix. This usually means the grouping variable or random effect has collinear levels or insufficient data."
          }
          showNotification(paste("Error in LME Post-hoc Analysis:", msg), type = "error")
          print(paste("LME Post-hoc Error Detail:", e$message))
        }
      )
    })
  })

  # Download handler for post-hoc results
  output$download_lme_posthoc <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_LME_PostHoc_", input$lme_posthoc_effect, "_", format(Sys.Date(), "%Y%m%d"), ".xlsx")
    },
    content = function(file) {
      req(posthoc_results())
      writexl::write_xlsx(list(lme_posthoc_results = posthoc_results()), file)
    }
  )

  # Return reactive values that might be needed elsewhere
  return(list(
    posthoc_results = posthoc_results,
    formula_used = formula_used
  ))
}
