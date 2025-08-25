bridge_sample_server <- function(input, output, session, merged_data) {
  
  observeEvent(input$select_bridge_samples, {
    req(merged_data())
    
    withProgress(message = 'Selecting bridge samples...', value = 0, {
      tryCatch({
        bridge_samples <- olink_bridgeselector(merged_data(), 
                                               n = input$num_bridge_samples, 
                                               sampleMissingFreq = input$missing_freq)
        output$bridge_sample_results <- renderPrint({
          print(bridge_samples)
        })
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in bridge sample selection:", e$message), type = "error")
      })
    })
  })
}