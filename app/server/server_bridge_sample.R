bridge_sample_server <- function(input, output, session, merged_data, npx_data_2) {
  observeEvent(input$select_bridge_samples, {
    req(merged_data())

    withProgress(message = "Selecting bridge samples...", value = 0, {
      tryCatch(
        {
          # TWO-DATASET MODE: If both datasets loaded, find overlapping samples
          if (!is.null(npx_data_2()) && nrow(npx_data_2()) > 0 && "Project" %in% colnames(merged_data())) {
            data <- merged_data()
            samples_df1 <- unique(data$SampleID[data$Project == "Dataset_1"])
            samples_df2 <- unique(data$SampleID[data$Project == "Dataset_2"])
            overlapping <- intersect(samples_df1, samples_df2)

            output$bridge_sample_results <- renderPrint({
              cat("Two-dataset bridge analysis:\n\n")
              cat("Dataset 1 samples:", length(samples_df1), "\n")
              cat("Dataset 2 samples:", length(samples_df2), "\n")
              cat("Overlapping (bridge) samples:", length(overlapping), "\n\n")

              if (length(overlapping) > 0) {
                cat("Bridge sample IDs:\n")
                cat(paste(overlapping, collapse = "\n"), "\n")
              } else {
                cat("WARNING: No overlapping samples found between datasets.\n")
                cat("Bridge normalization requires shared samples present in both NPX files.\n")
              }
            })
          } else {
            # SINGLE-DATASET MODE: Use olink_bridgeselector
            bridge_samples <- olink_bridgeselector(merged_data(),
              n = input$num_bridge_samples,
              sampleMissingFreq = input$missing_freq
            )
            output$bridge_sample_results <- renderPrint({
              print(bridge_samples)
            })
          }

          incProgress(1)
        },
        error = function(e) {
          showNotification(paste("Error in bridge sample selection:", e$message), type = "error")
        }
      )
    })
  })
}
