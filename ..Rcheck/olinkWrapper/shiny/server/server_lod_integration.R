lod_integration_server <- function(input, output, session, merged_data, exclusion_log = NULL) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  below_lod_proteins <- reactiveVal(NULL)
  
  observeEvent(input$integrate_lod, {
    req(merged_data())
    
    withProgress(message = 'Integrating LOD information...', value = 0, {
      tryCatch({
        data <- merged_data()
        
        if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
           data <- data %>% rename(SampleID = Sample_ID)
        }
        
        if ("LOD" %in% colnames(data)) {
          showNotification("LOD column already exists.", type = "message")
          data_with_lod <- data
        } else {
          required_metadata <- c("SampleType", "DataAnalysisRefID", "SampleQC", "AssayType")
          for (col in required_metadata) {
            if (!(col %in% colnames(data))) {
              if (col == "SampleType") data$SampleType <- "Sample"
              else if (col == "SampleQC") data$SampleQC <- "QC"
              else data[[col]] <- "Unknown"
            }
          }
          
          data_with_lod <- tryCatch({
            olink_lod(data)
          }, error = function(e) {
            stop(paste("LOD calculation failed:", e$message, "\nTip: Ensure your input file has an 'LOD' column OR contains at least 10 Negative Control samples."))
          })
        }

        merged_data(data_with_lod)
        
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
          cat("Proteins with >50% below LOD:", nrow(high_below_lod), "\n")
        })
        
        output$below_lod_table <- DT::renderDataTable({
          DT::datatable(high_below_lod, 
                       extensions = 'Buttons',
                       options = list(
                         pageLength = 10,
                         dom = 'Bflrtip',
                         buttons = list(
                           list(extend = "excel", text = "Download current page", 
                                filename = paste0("olinkWrapper_", VERSION, "_LOD_Summary_", format(Sys.Date(), "%Y%m%d")),
                                exportOptions = list(modifier = list(page = "current")))
                         )
                       )) %>%
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
    if (length(proteins_to_remove) == 0) return()
    
    withProgress(message = 'Filtering proteins...', value = 0, {
      before_data <- merged_data()
      new_data <- before_data %>% filter(!(Assay %in% proteins_to_remove))
      merged_data(new_data)
      
      # Log exclusion
      if (!is.null(exclusion_log)) {
        current_log <- exclusion_log()
        current_log[[length(current_log) + 1]] <- list(
          step      = "LOD Filtering",
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          description = paste("Removed", length(proteins_to_remove), "proteins (>50% below LOD)."),
          proteins_excluded = proteins_to_remove
        )
        exclusion_log(current_log)
      }

      below_lod_proteins(NULL)
      output$below_lod_table <- DT::renderDataTable(NULL)
      incProgress(1)
    })
  })
}