lod_integration_server <- function(input, output, session, merged_data) {
  
  # Reactive value to store proteins with >50% below LOD
  below_lod_proteins <- reactiveVal(NULL)
  
  observeEvent(input$integrate_lod, {
    req(merged_data())
    
    withProgress(message = 'Integrating LOD information...', value = 0, {
      tryCatch({
        data <- merged_data()
        
        # 1. Column Name Normalization
        # Try to find SampleID and Assay columns even if they have underscores
        if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
           data <- data %>% rename(SampleID = Sample_ID)
        }
        
        # 2. Check if LOD already exists
        if ("LOD" %in% colnames(data)) {
          showNotification("LOD column already exists. Using existing values.", type = "message")
          data_with_lod <- data
        } else {
          # Attempt to integrate LOD using OlinkAnalyze
          # Map dummy metadata columns required by olink_lod()
          required_metadata <- c("SampleType", "DataAnalysisRefID", "SampleQC", "AssayType")
          for (col in required_metadata) {
            if (!(col %in% colnames(data))) {
              if (col == "SampleType") data$SampleType <- "Sample"
              else if (col == "SampleQC") data$SampleQC <- "QC"
              else data[[col]] <- "Unknown"
            }
          }
          
          # Try to calculate or merge LOD
          # If this fails because of negative controls, it means we don't have the ref data
          data_with_lod <- tryCatch({
            olink_lod(data)
          }, error = function(e) {
            msg <- paste("LOD calculation failed:", e$message, 
                         "\nTip: Ensure your input file has an 'LOD' column OR contains at least 10 Negative Control samples.")
            stop(msg)
          })
        }

        
        merged_data(data_with_lod)
        
        # 3. Calculate percentage below LOD
        # Ensure we use valid column names for the calculation
        lod_stats <- data_with_lod %>%
          group_by(Assay) %>%
          summarize(
            Total = n(),
            BelowLOD = sum(NPX < LOD, na.rm = TRUE),
            PercentBelowLOD = (BelowLOD / Total) * 100
          ) %>%
          arrange(desc(PercentBelowLOD))
        
        high_below_lod <- lod_stats %>% filter(PercentBelowLOD > 50)
        below_lod_proteins(high_below_lod)
        
        output$lod_integration_results <- renderPrint({
          cat("LOD information processed.\n")
          cat("Number of samples:", length(unique(data_with_lod$SampleID)), "\n")
          cat("Number of assays:", length(unique(data_with_lod$Assay)), "\n")
          cat("Proteins with >50% below LOD:", nrow(high_below_lod), "\n")
        })
        
        output$below_lod_table <- DT::renderDataTable({
          DT::datatable(high_below_lod, options = list(pageLength = 10)) %>%
            DT::formatRound("PercentBelowLOD", 2)
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in LOD integration:", e$message), type = "error")
      })
    })
  })
  
  observeEvent(input$filter_lod_proteins, {
    req(merged_data(), below_lod_proteins())
    
    proteins_to_remove <- below_lod_proteins()$Assay
    if (length(proteins_to_remove) == 0) {
      showNotification("No proteins to remove.", type = "message")
      return()
    }
    
    withProgress(message = 'Filtering proteins...', value = 0, {
      new_data <- merged_data() %>%
        filter(!(Assay %in% proteins_to_remove))
      
      merged_data(new_data)
      showNotification(paste("Removed", length(proteins_to_remove), "proteins."), type = "message")
      
      below_lod_proteins(NULL)
      output$below_lod_table <- DT::renderDataTable(NULL)
      incProgress(1)
    })
  })
}