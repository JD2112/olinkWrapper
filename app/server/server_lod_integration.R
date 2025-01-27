lod_integration_server <- function(input, output, session, merged_data) {
  
  observeEvent(input$integrate_lod, {
    req(merged_data())
    
    withProgress(message = 'Integrating LOD information...', value = 0, {
      tryCatch({
        data_with_lod <- olink_lod(merged_data())
        merged_data(data_with_lod)  # Update the merged_data reactive value
        output$lod_integration_results <- renderPrint({
          cat("LOD information has been integrated into the dataset.\n")
          cat("Number of samples:", nrow(data_with_lod), "\n")
          cat("Number of assays:", length(unique(data_with_lod$Assay)), "\n")
        })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in LOD integration:", e$message), type = "error")
      })
    })
  })
}