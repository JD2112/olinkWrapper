data_preview_server <- function(input, output, session, merged_data, var_key_merged, exclusion_log = NULL) {
  output$data_preview <- renderDT({
    req(merged_data())
    datatable(merged_data(),
      extensions = c("Buttons"),
      options = list(
        paging = TRUE,
        searching = TRUE,
        fixedColumns = TRUE,
        autowidth = TRUE,
        ordering = TRUE,
        dom = "Bflrtip",
        lengthMenu = list(
          c(10, 25, 50, 100, 1000, -1),
          c("10", "25", "50", "100", "1000", "All")
        ),
        scrollX = TRUE,
        buttons = list(
          list(
            extend = "excel",
            text = "Download current page",
            filename = "Merged data (current page)",
            exportOptions = list(
              modifier = list(page = "current")
            )
          )
        )
      )
    )
  })

  observeEvent(input$filter_qc_warnings, {
    req(merged_data())

    data <- merged_data()
    if (!"QC_Warning" %in% colnames(data)) {
      showNotification("QC_Warning column not found in dataset.", type = "error")
      return()
    }

    # Count original data
    original_samples <- length(unique(data$SampleID))
    original_proteins <- length(unique(data$Assay))
    original_rows <- nrow(data)

    # Identify rows with QC warnings
    # Olink data QC_Warning can contain:
    #   - "Pass" or "PASS" or NA/empty for good measurements
    #   - "Warning" or "WARN" or assay name for failed measurements
    # We consider a row "passed" if QC_Warning is NA, empty, "Pass", or "PASS"
    pass_values <- c("Pass", "PASS", "pass", "")
    failed_qc_rows <- data %>%
      filter(!is.na(QC_Warning) & !(QC_Warning %in% pass_values))

    if (nrow(failed_qc_rows) == 0) {
      showNotification("No QC warnings found. All measurements have QC_Warning = 'PASS'.", type = "message")
      return()
    }

    # Identify which proteins had QC failures
    warning_proteins <- unique(failed_qc_rows$Assay)

    # Identify which samples had QC failures (for informational purposes)
    warning_samples <- unique(failed_qc_rows$SampleID)

    # Count how many measurements failed per protein
    protein_failure_counts <- failed_qc_rows %>%
      group_by(Assay) %>%
      summarize(n_failures = n()) %>%
      arrange(desc(n_failures))

    withProgress(message = "Filtering QC warnings...", value = 0, {
      # Keep only rows where QC_Warning indicates a pass
      new_data <- data %>% filter(is.na(QC_Warning) | QC_Warning %in% pass_values)

      merged_data(new_data)

      # Count new data
      new_samples <- length(unique(new_data$SampleID))
      new_proteins <- length(unique(new_data$Assay))
      new_rows <- nrow(new_data)

      output$qc_filter_status <- renderPrint({
        cat("=== QC Warning Exclusion Summary ===\n\n")

        cat("Removed", original_rows - new_rows, "measurements that failed QC\n\n")

        cat("Proteins with QC failures:\n")
        for (i in 1:nrow(protein_failure_counts)) {
          cat(
            "  -", protein_failure_counts$Assay[i], ":",
            protein_failure_counts$n_failures[i], "failed measurements\n"
          )
        }
        cat("\n")

        cat("Samples affected:", length(warning_samples), "samples had at least one failed measurement\n\n")

        cat("Dataset Summary:\n")
        cat("  Samples: ", original_samples, " → ", new_samples,
          " (", original_samples - new_samples, " removed)\n",
          sep = ""
        )
        cat("  Proteins: ", original_proteins, " → ", new_proteins,
          " (", original_proteins - new_proteins, " removed)\n",
          sep = ""
        )
        cat("  Total measurements: ", original_rows, " → ", new_rows,
          " (", original_rows - new_rows, " removed)\n",
          sep = ""
        )
      })

      showNotification(
        paste("Removed", original_rows - new_rows, "measurements with QC warnings. Kept only 'PASS' measurements."),
        type = "message",
        duration = 5
      )

      # Append to shared exclusion log
      if (!is.null(exclusion_log)) {
        current_log <- exclusion_log()
        current_log[[length(current_log) + 1]] <- list(
          step = "A. Data Preview – Exclude samples with QC Warning",
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          description = paste(
            "Removed", original_rows - new_rows,
            "measurements flagged with QC warnings (QC_Warning != 'PASS').",
            "Proteins affected:", paste(warning_proteins, collapse = ", ")
          ),
          samples_excluded = warning_samples,
          proteins_excluded = warning_proteins,
          before = list(samples = original_samples, proteins = original_proteins, rows = original_rows),
          after = list(samples = new_samples, proteins = new_proteins, rows = new_rows),
          notes = ""
        )
        exclusion_log(current_log)
      }

      incProgress(1)
    })
  })

  output$download_full_data <- downloadHandler(
    filename = function() {
      paste("full_dataset_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(merged_data(), file, row.names = FALSE)
    }
  )

  output$download_var_key_data <- downloadHandler(
    filename = function() {
      paste("var_key_merged_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      req(var_key_merged())
      write.csv(var_key_merged(), file, row.names = FALSE)
    }
  )
}
