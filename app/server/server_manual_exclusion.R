# Manual Exclusion Server

manual_exclusion_server <- function(input, output, session, merged_data) {
  
  # Reactive values to store exclusion lists
  samples_to_exclude <- reactiveVal(character(0))
  proteins_to_exclude <- reactiveVal(character(0))
  
  # Preview sample exclusion
  observeEvent(input$preview_sample_exclusion, {
    req(merged_data())
    
    data <- merged_data()
    exclude_list <- character(0)
    
    # Parse manual input
    if (!is.null(input$manual_exclude_samples) && input$manual_exclude_samples != "") {
      manual_samples <- trimws(unlist(strsplit(input$manual_exclude_samples, ",")))
      manual_samples <- manual_samples[manual_samples != ""]
      exclude_list <- c(exclude_list, manual_samples)
    }
    
    # Add controls if checkbox is selected
    if (input$exclude_all_controls && "SampleType" %in% colnames(data)) {
      control_samples <- data %>%
        filter(SampleType == "CONTROL") %>%
        distinct(SampleID) %>%
        pull(SampleID)
      exclude_list <- c(exclude_list, control_samples)
    }
    
    # Remove duplicates
    exclude_list <- unique(exclude_list)
    
    # Check which samples actually exist in the dataset
    existing_samples <- unique(data$SampleID)
    valid_exclusions <- exclude_list[exclude_list %in% existing_samples]
    invalid_exclusions <- exclude_list[!exclude_list %in% existing_samples]
    
    # Store for later application
    samples_to_exclude(valid_exclusions)
    
    # Display preview
    output$sample_exclusion_preview <- renderPrint({
      cat("=== Sample Exclusion Preview ===\n\n")
      
      if (length(valid_exclusions) > 0) {
        cat("Samples to be excluded (", length(valid_exclusions), "):\n", sep = "")
        cat(paste(valid_exclusions, collapse = ", "), "\n\n")
      } else {
        cat("No valid samples to exclude.\n\n")
      }
      
      if (length(invalid_exclusions) > 0) {
        cat("WARNING: The following samples were not found in the dataset:\n")
        cat(paste(invalid_exclusions, collapse = ", "), "\n\n")
      }
      
      cat("Current total samples:", length(existing_samples), "\n")
      cat("Samples after exclusion:", length(existing_samples) - length(valid_exclusions), "\n")
    })
  })
  
  # Preview protein exclusion
  observeEvent(input$preview_protein_exclusion, {
    req(merged_data())
    
    data <- merged_data()
    exclude_list <- character(0)
    
    # Parse manual input
    if (!is.null(input$manual_exclude_proteins) && input$manual_exclude_proteins != "") {
      manual_proteins <- trimws(unlist(strsplit(input$manual_exclude_proteins, ",")))
      manual_proteins <- manual_proteins[manual_proteins != ""]
      exclude_list <- c(exclude_list, manual_proteins)
    }
    
    # Remove duplicates
    exclude_list <- unique(exclude_list)
    
    # Check which proteins actually exist in the dataset
    existing_proteins <- unique(data$Assay)
    valid_exclusions <- exclude_list[exclude_list %in% existing_proteins]
    invalid_exclusions <- exclude_list[!exclude_list %in% existing_proteins]
    
    # Store for later application
    proteins_to_exclude(valid_exclusions)
    
    # Display preview
    output$protein_exclusion_preview <- renderPrint({
      cat("=== Protein Exclusion Preview ===\n\n")
      
      if (length(valid_exclusions) > 0) {
        cat("Proteins to be excluded (", length(valid_exclusions), "):\n", sep = "")
        cat(paste(valid_exclusions, collapse = ", "), "\n\n")
      } else {
        cat("No valid proteins to exclude.\n\n")
      }
      
      if (length(invalid_exclusions) > 0) {
        cat("WARNING: The following proteins were not found in the dataset:\n")
        cat(paste(invalid_exclusions, collapse = ", "), "\n\n")
      }
      
      cat("Current total proteins:", length(existing_proteins), "\n")
      cat("Proteins after exclusion:", length(existing_proteins) - length(valid_exclusions), "\n")
    })
  })
  
  # Apply all exclusions
  observeEvent(input$apply_manual_exclusions, {
    req(merged_data())
    
    data <- merged_data()
    samples_exclude <- samples_to_exclude()
    proteins_exclude <- proteins_to_exclude()
    
    if (length(samples_exclude) == 0 && length(proteins_exclude) == 0) {
      showNotification("No exclusions to apply. Please preview exclusions first.", type = "warning")
      return()
    }
    
    withProgress(message = 'Applying exclusions...', value = 0, {
      original_samples <- length(unique(data$SampleID))
      original_proteins <- length(unique(data$Assay))
      
      # Apply sample exclusions
      if (length(samples_exclude) > 0) {
        data <- data %>% filter(!(SampleID %in% samples_exclude))
      }
      
      incProgress(0.5)
      
      # Apply protein exclusions
      if (length(proteins_exclude) > 0) {
        data <- data %>% filter(!(Assay %in% proteins_exclude))
      }
      
      # Update the merged data
      merged_data(data)
      
      # Display summary
      output$exclusion_summary <- renderPrint({
        cat("=== Exclusion Applied Successfully ===\n\n")
        
        if (length(samples_exclude) > 0) {
          cat("Excluded", length(samples_exclude), "sample(s):\n")
          cat(paste(samples_exclude, collapse = ", "), "\n\n")
        }
        
        if (length(proteins_exclude) > 0) {
          cat("Excluded", length(proteins_exclude), "protein(s):\n")
          cat(paste(proteins_exclude, collapse = ", "), "\n\n")
        }
        
        cat("Dataset Summary:\n")
        cat("  Samples: ", original_samples, " → ", length(unique(data$SampleID)), "\n", sep = "")
        cat("  Proteins: ", original_proteins, " → ", length(unique(data$Assay)), "\n", sep = "")
        cat("  Total measurements: ", nrow(data), "\n", sep = "")
      })
      
      # Clear the exclusion lists and inputs
      samples_to_exclude(character(0))
      proteins_to_exclude(character(0))
      updateTextAreaInput(session, "manual_exclude_samples", value = "")
      updateTextAreaInput(session, "manual_exclude_proteins", value = "")
      updateCheckboxInput(session, "exclude_all_controls", value = FALSE)
      
      showNotification(
        paste("Exclusions applied:", length(samples_exclude), "samples and", 
              length(proteins_exclude), "proteins removed."),
        type = "message",
        duration = 5
      )
      
      incProgress(1)
    })
  })
}
