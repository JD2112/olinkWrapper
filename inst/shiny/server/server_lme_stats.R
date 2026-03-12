lme_stats_server <- function(input, output, session, merged_data, lme_results, analysis_log) {
  # App Version
  VERSION <- APP_VERSION # Set globally by version.R

  # Update UI choices based on available data
  observe({
    req(merged_data())
    cols <- names(merged_data())
    # Exclude proteomic technical columns from modeling choices
    exclude_cols <- c(
      "OlinkID", "UniProt", "Assay", "MissingFreq", "Panel",
      "Panel_Lot_Nr", "PlateID", "QC_Warning", "LOD", "Normalization",
      "Assay_Warning", "ExploreVersion"
    )
    model_choices <- setdiff(cols, exclude_cols)

    updateSelectInput(session, "lmer_outcome",
      choices = intersect(c("NPX", model_choices), cols),
      selected = "NPX"
    )
    updateSelectInput(session, "lmer_fixed", choices = setdiff(model_choices, "NPX"))
    updateSelectInput(session, "lmer_random", choices = model_choices)
  })

  # Linear Mixed Effects Model
  observeEvent(input$run_lmer, {
    req(merged_data(), input$lmer_outcome, input$lmer_fixed, input$lmer_random)

    withProgress(message = "Running Linear Mixed Effects Model...", value = 0, {
      tryCatch(
        {
          data_for_lme <- merged_data()

          # Convert selected character fixed/random effects to factors
          for (var in c(input$lmer_fixed, input$lmer_random)) {
            if (is.character(data_for_lme[[var]])) {
              data_for_lme[[var]] <- as.factor(data_for_lme[[var]])
            }
          }

          # SANITY CHECK: LME requires at least some subjects with repeated measures
          # If every SubjectID has only 1 row, olink_lmer will crash with technical error
          test_protein <- unique(data_for_lme$OlinkID)[1]
          test_obs <- data_for_lme %>% filter(OlinkID == test_protein)
          if (n_distinct(test_obs[[input$lmer_random[1]]]) >= nrow(test_obs)) {
            stop("Each subject has only one observation (cross-sectional data). LME modeling requires longitudinal/repeated measures. Please use the Linear Regression or ANOVA modules instead.")
          }

          formula <- as.formula(paste(
            input$lmer_outcome, "~",
            paste(input$lmer_fixed, collapse = " + "),
            "+ (1|", paste(input$lmer_random, collapse = ") + (1|"), ")"
          ))

          results <- olink_lmer(data_for_lme, model_formula = formula)

          output$lmer_results <- renderPrint({
            cat("Model Formula:\n")
            cat(paste0(deparse(formula, width.cutoff = 500), collapse = ""), "\n\n")
          })

          # Store results and model details
          lme_results(list(
            results = results,
            model_details = list(
              variable = input$lmer_outcome,
              fixed = input$lmer_fixed,
              random = input$lmer_random
            )
          ))

          # Log analysis
          log_analysis(analysis_log, "LME",
            paste("Outcome:", input$lmer_outcome, "| Fixed:", paste(input$lmer_fixed, collapse = ", "), "| Random:", paste(input$lmer_random, collapse = ", ")),
            table = results
          )

          output$lme_npx_table <- renderDT({
            datatable(results,
              extensions = c("Buttons"),
              options = list(
                scrollX = TRUE,
                dom = "Bflrtip",
                buttons = list(
                  list(
                    extend = "excel",
                    text = "Download current page",
                    filename = paste0("olinkWrapper_", VERSION, "_LME_Stats_", input$lmer_outcome, "_", format(Sys.Date(), "%Y%m%d")),
                    exportOptions = list(modifier = list(page = "current"))
                  )
                )
              )
            )
          })

          incProgress(1)
          showNotification("LME model calculation completed.", type = "message")
        },
        error = function(e) {
          showNotification(paste("Error in Linear Mixed Effects Model:", e$message), type = "error")
        }
      )
    })
  })
}
