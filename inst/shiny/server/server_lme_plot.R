lme_plot_server <- function(input, output, session, merged_data, analysis_log) {
  # App Version
  VERSION <- APP_VERSION # Set globally by version.R

  # Update input choices
  observe({
    req(merged_data())
    cols <- names(merged_data())
    # Exclude proteomic technical columns from aesthetic/model mapping
    exclude_cols <- c(
      "SampleID", "OlinkID", "UniProt", "Assay", "MissingFreq", "Panel",
      "Panel_Lot_Nr", "PlateID", "QC_Warning", "LOD", "NPX",
      "Normalization", "Assay_Warning", "ExploreVersion"
    )
    mapping_cols <- setdiff(cols, exclude_cols)

    updateSelectizeInput(session, "lme_plot_olinkid_list", choices = unique(merged_data()$OlinkID))
    updateSelectizeInput(session, "lme_plot_variable", choices = mapping_cols)
    updateSelectInput(session, "lme_plot_random", choices = mapping_cols)
    updateSelectInput(session, "lme_plot_x_axis_variable", choices = mapping_cols)
    updateSelectInput(session, "lme_plot_col_variable", choices = mapping_cols)
  })

  # Generate LME plot
  lme_plot_data <- eventReactive(input$generate_lme_plot, {
    req(
      merged_data(), input$lme_plot_variable, input$lme_plot_random,
      input$lme_plot_x_axis_variable, input$lme_plot_col_variable
    )

    withProgress(message = "Fitting models and generating LME plot...", value = 0, {
      # Generate plot using olink_lmer_plot
      tryCatch(
        {
          print("Generating LME plot...")

          # SMART FIX: OlinkAnalyze requires all plot variables to be in the predictor list
          # We merge them here automatically to prevent UI errors and model mismatches
          final_vars <- unique(c(
            input$lme_plot_variable,
            input$lme_plot_col_variable,
            input$lme_plot_x_axis_variable
          ))

          # SAFETY: NPX is the response variable, remove it from fixed effects if accidentally selected
          final_vars <- final_vars[final_vars != "NPX"]

          if (input$lme_plot_x_axis_variable == "NPX") {
            stop("NPX is the response variable (Y-axis) and cannot be used as the X-axis variable.")
          }

          # Prepare data: Convert categorical predictors to factors for model stability
          plot_data_prep <- merged_data()
          for (v in final_vars) {
            if (is.character(plot_data_prep[[v]])) {
              plot_data_prep[[v]] <- as.factor(plot_data_prep[[v]])
            }
          }
          if (is.character(plot_data_prep[[input$lme_plot_random]])) {
            plot_data_prep[[input$lme_plot_random]] <- as.factor(plot_data_prep[[input$lme_plot_random]])
          }

          # SANITY CHECK: LME Plot (olink_lmer_plot) will fail if data is cross-sectional
          # Checking a single protein to verify observation count per ID
          test_protein <- unique(plot_data_prep$OlinkID)[1]
          test_obs <- plot_data_prep[plot_data_prep$OlinkID == test_protein, ]
          if (nrow(test_obs) > 0 && n_distinct(test_obs[[input$lme_plot_random]]) >= nrow(test_obs)) {
            stop("Each SubjectID only has one sample in the current dataset. LME plots require repeated measures (longitudinal data). Try using Boxplots or Violin plots for this dataset.")
          }

          # OlinkAnalyze::olink_lmer_plot returns a faceted ggplot or list of plots
          plot <- olink_lmer_plot(
            df = plot_data_prep,
            variable = final_vars,
            x_axis_variable = input$lme_plot_x_axis_variable,
            col_variable = input$lme_plot_col_variable,
            random = input$lme_plot_random,
            olinkid_list = if (length(input$lme_plot_olinkid_list) > 0) input$lme_plot_olinkid_list else NULL
          )

          # Log analysis
          log_analysis(analysis_log, "LME Plots",
            paste("Outcome:", input$lme_plot_variable, "| Random:", input$lme_plot_random),
            plot = if (inherits(plot, "list")) plot[[1]] else plot
          )

          incProgress(1)
          plot
        },
        error = function(e) {
          print(paste("Error in olink_lmer_plot:", e$message))
          showNotification(paste("Error generating LME plot:", e$message), type = "error")
          NULL
        }
      )
    })
  })

  # Render LME plot
  output$lme_plot_output <- renderPlot({
    req(lme_plot_data())
    plot_data <- lme_plot_data()
    if (is.null(plot_data)) {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "Error generating LME plot. Please check your data and selections.", cex = 1.2)
    } else {
      # Handle if it's a list or ggplot
      if (inherits(plot_data, "list")) {
        cowplot::plot_grid(plotlist = plot_data)
      } else {
        plot_data
      }
    }
  })

  # Download handler
  output$download_lme_plot <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_", VERSION, "_LME_Plot_", input$lme_plot_variable[1], "_", format(Sys.Date(), "%Y%m%d"), ".png")
    },
    content = function(file) {
      req(lme_plot_data())
      p <- lme_plot_data()
      if (inherits(p, "list")) {
        p <- cowplot::plot_grid(plotlist = p)
      }
      ggsave(file, plot = p, device = "png", width = 12, height = 10)
    }
  )
}
