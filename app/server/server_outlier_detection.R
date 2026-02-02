library(OlinkAnalyze)
library(ggplot2)
library(umap)
library(dplyr)
library(tidyr)
library(tibble)

outlier_detection_server <- function(input, output, session, merged_data) {
  
  # Reactive value to store outlier IDs
  detected_outlier_ids <- reactiveVal(NULL)
  
  observeEvent(input$detect_outliers, {
    req(merged_data())
    
    withProgress(message = 'Detecting outliers...', value = 0, {
      tryCatch({
        data <- merged_data()
        
        # Column Name Normalization
        if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
           data <- data %>% rename(SampleID = Sample_ID)
        }
        
        # Remove assays with all NA values
        valid_data <- data %>%
          group_by(Assay) %>%
          filter(!all(is.na(NPX))) %>%
          ungroup()
        
        # Prepare data for UMAP
        umap_data <- valid_data %>%
          select(SampleID, Assay, NPX) %>%
          pivot_wider(names_from = Assay, values_from = NPX) %>%
          tibble::column_to_rownames("SampleID")
        
        # Check for missing values
        missing_proportion <- sum(is.na(umap_data)) / prod(dim(umap_data))
        
        if (missing_proportion > 0.8) {
          stop(paste0("Too many missing values (", round(missing_proportion * 100, 2), "%). Cannot perform outlier detection."))
        }
        
        # Impute missing values with column medians
        umap_data_filled <- apply(umap_data, 2, function(x) {
          if (all(is.na(x))) return(rep(0, length(x)))
          ifelse(is.na(x), median(x, na.rm = TRUE), x)
        })
        
        # Ensure all values are numeric
        umap_data_filled <- apply(umap_data_filled, 2, as.numeric)
        
        # Run UMAP
        umap_result <- umap(umap_data_filled)
        
        umap_coords <- as.data.frame(umap_result$layout)
        colnames(umap_coords) <- c("UMAP1", "UMAP2")
        umap_coords$SampleID <- rownames(umap_data)
        
        # Calculate distances and identify outliers
        distances <- as.matrix(dist(umap_coords[, c("UMAP1", "UMAP2")]))
        mean_distances <- colMeans(distances, na.rm = TRUE)
        
        outlier_threshold <- mean(mean_distances, na.rm = TRUE) + 
                             input$outlier_threshold * sd(mean_distances, na.rm = TRUE)
        
        outliers <- mean_distances > outlier_threshold
        
        # Ensure outliers is a logical vector
        outliers <- as.logical(outliers)
        
        umap_coords$outlier <- outliers
        
        # Store outlier IDs
        outlier_ids <- umap_coords$SampleID[outliers]
        detected_outlier_ids(outlier_ids)
        
        # Create plot with outliers highlighted
        p <- ggplot(umap_coords, aes(x = UMAP1, y = UMAP2, color = outlier)) +
          geom_point() +
          scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
          labs(title = "UMAP Plot with Outliers", color = "Outlier") +
          theme_minimal()
        
        # Render the plot within the Shiny app
        output$outlier_umap_plot <- renderPlot({
          p
        })
        
        output$outlier_exclusion_status <- renderPrint({
          if (length(outlier_ids) > 0) {
            cat("Detected", length(outlier_ids), "outliers:\n")
            cat(paste(outlier_ids, collapse = ", "), "\n")
          } else {
            cat("No outliers detected with current threshold.")
          }
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in outlier detection:", e$message), type = "error")
      })
    })
  })
  
  observeEvent(input$exclude_outliers, {
    req(merged_data(), detected_outlier_ids())
    
    outliers_to_remove <- detected_outlier_ids()
    if (length(outliers_to_remove) == 0) {
      showNotification("No outliers found to exclude.", type = "message")
      return()
    }
    
    withProgress(message = 'Excluding outliers...', value = 0, {
      data <- merged_data()
      # Normalize here too
      if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
         data <- data %>% rename(SampleID = Sample_ID)
      }
      
      new_data <- data %>%
        filter(!(SampleID %in% outliers_to_remove))
      
      merged_data(new_data)
      showNotification(paste("Excluded", length(outliers_to_remove), "outlier samples."), type = "message")
      
      # Reset
      detected_outlier_ids(NULL)
      output$outlier_exclusion_status <- renderPrint(cat("Outliers excluded."))
      
      incProgress(1)
    })
  })
}