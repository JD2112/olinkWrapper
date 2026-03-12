normalization_server <- function(input, output, session, merged_data, npx_data_2) {
  print("normalization_server function called")

  # Update reference sample choices based on available data
  observe({
    print("Observe block in normalization_server triggered")
    req(merged_data())
    sample_ids <- unique(merged_data()$SampleID)
    print(paste("Number of unique SampleIDs:", length(sample_ids)))
    updateSelectInput(session, "ref_sample", choices = sample_ids)
  })

  # Perform normalization when button is clicked
  observeEvent(input$normalize, {
    print("Normalize button clicked")
    req(merged_data(), input$ref_sample)

    withProgress(message = "Normalizing data...", value = 0, {
      tryCatch(
        {
          print("Starting normalization")
          print(paste("Reference sample:", input$ref_sample))

          data <- merged_data()

          # TWO-DATASET NORMALIZATION: If a second NPX file was uploaded, use it as df2
          if (!is.null(npx_data_2()) && nrow(npx_data_2()) > 0) {
            print("Using two-dataset normalization (NPX File 1 vs NPX File 2)")

            # Identify overlapping samples between both datasets
            samples_df1 <- unique(data$SampleID[data$Project == "Dataset_1"])
            samples_df2 <- unique(data$SampleID[data$Project == "Dataset_2"])
            overlapping <- intersect(samples_df1, samples_df2)

            df1 <- data[data$Project == "Dataset_1", ]
            df2 <- data[data$Project == "Dataset_2", ]

            if (length(overlapping) > 0) {
              print(paste("Found", length(overlapping), "overlapping bridge samples"))
              normalized <- OlinkAnalyze::olink_normalization(
                df1 = df1,
                df2 = df2,
                overlapping_samples_df1 = overlapping,
                overlapping_samples_df2 = overlapping,
                df1_project_nr = "Dataset_1",
                df2_project_nr = "Dataset_2",
                reference_project = "Dataset_1"
              )
            } else {
              print("No overlapping samples found, using reference-based normalization")
              normalized <- OlinkAnalyze::olink_normalization(
                df1 = df1,
                df2 = df2,
                overlapping_samples_df1 = NULL,
                overlapping_samples_df2 = NULL,
                df1_project_nr = "Dataset_1",
                df2_project_nr = "Dataset_2",
                reference_project = "Dataset_1"
              )
            }
          } else {
            # SINGLE-DATASET NORMALIZATION: Split by reference sample
            print("Using single-dataset normalization (reference sample)")
            reference_data <- data[data$SampleID == input$ref_sample, ]
            other_data <- data[data$SampleID != input$ref_sample, ]

            normalized <- OlinkAnalyze::olink_normalization(
              df1 = other_data,
              df2 = reference_data,
              overlapping_samples_df1 = NULL,
              overlapping_samples_df2 = NULL,
              df1_project_nr = "Other",
              df2_project_nr = "Reference",
              reference_project = "Reference"
            )
          }

          print("Normalization completed")
          incProgress(1)
          merged_data(normalized) # Update the merged_data reactive value
          print("merged_data updated with normalized data")
          showNotification("Normalization completed successfully.", type = "message")
        },
        error = function(e) {
          print(paste("Error in normalization:", e$message))
          showNotification(paste("Error in normalization:", e$message), type = "error")
        }
      )
    })
  })

  # Display summary of normalization
  output$norm_summary <- renderPrint({
    print("Rendering normalization summary")
    req(merged_data())
    cat("Normalization summary:\n")
    cat("Number of samples:", length(unique(merged_data()$SampleID)), "\n")
    cat("Number of assays:", length(unique(merged_data()$Assay)), "\n")

    # Show two-dataset info if available
    if (!is.null(npx_data_2()) && nrow(npx_data_2()) > 0) {
      cat("Mode: Two-dataset normalization\n")
      if ("Project" %in% colnames(merged_data())) {
        cat("Dataset 1 samples:", length(unique(merged_data()$SampleID[merged_data()$Project == "Dataset_1"])), "\n")
        cat("Dataset 2 samples:", length(unique(merged_data()$SampleID[merged_data()$Project == "Dataset_2"])), "\n")
      }
    } else {
      cat("Mode: Single-dataset normalization\n")
      cat("Reference sample:", input$ref_sample, "\n")
    }
  })
}
