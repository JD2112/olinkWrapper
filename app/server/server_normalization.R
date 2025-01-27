normalization_server <- function(input, output, session, merged_data) {
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
    
    withProgress(message = 'Normalizing data...', value = 0, {
      tryCatch({
        print("Starting normalization")
        print(paste("Reference sample:", input$ref_sample))
        
        # Split the data into two parts
        data <- merged_data()
        reference_data <- data[data$SampleID == input$ref_sample, ]
        other_data <- data[data$SampleID != input$ref_sample, ]
        
        # Perform normalization
        normalized <- OlinkAnalyze::olink_normalization(
          df1 = other_data,
          df2 = reference_data,
          overlapping_samples_df1 = NULL,
          overlapping_samples_df2 = NULL,
          df1_project_nr = "Other",
          df2_project_nr = "Reference",
          reference_project = "Reference"
        )
        
        print("Normalization completed")
        incProgress(1)
        merged_data(normalized)  # Update the merged_data reactive value
        print("merged_data updated with normalized data")
        showNotification("Normalization completed successfully.", type = "message")
      }, error = function(e) {
        print(paste("Error in normalization:", e$message))
        showNotification(paste("Error in normalization:", e$message), type = "error")
      })
    })
  })
  
  # Display summary of normalization
  output$norm_summary <- renderPrint({
    print("Rendering normalization summary")
    req(merged_data())
    cat("Normalization summary:\n")
    cat("Number of samples:", length(unique(merged_data()$SampleID)), "\n")
    cat("Number of assays:", length(unique(merged_data()$Assay)), "\n")
    cat("Reference sample:", input$ref_sample, "\n")
  })
}