library(OlinkAnalyze)
library(ggplot2)
library(umap)
library(dplyr)
library(tidyr)
library(tibble)

outlier_detection_server <- function(input, output, session, merged_data) {
  
  observeEvent(input$detect_outliers, {
    req(merged_data())
    
    withProgress(message = 'Detecting outliers...', value = 0, {
      tryCatch({
        # Remove assays with all NA values
        valid_data <- merged_data() %>%
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
        
        if (missing_proportion > 0.5) {
          stop(paste0("Too many missing values (", round(missing_proportion * 100, 2), "%). Cannot perform outlier detection."))
        }
        
        # Impute missing values with column medians
        umap_data <- apply(umap_data, 2, function(x) {
          ifelse(is.na(x), median(x, na.rm = TRUE), x)
        })
        
        # Ensure all values are numeric
        umap_data <- apply(umap_data, 2, as.numeric)
        
        # Run UMAP
        umap_result <- umap(umap_data)
        
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
        
        # Create plot with outliers highlighted
        p <- ggplot(umap_coords, aes(x = UMAP1, y = UMAP2, color = outlier)) +
          geom_point() +
          scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
          labs(title = "UMAP Plot with Outliers", color = "Outlier") +
          theme_minimal()
        
        # Render the plot within the Shiny app
        output$outlier_umap_plot <- renderPlot({
          print(p)
        })
        
        incProgress(1)
      }, error = function(e) {
        showNotification(paste("Error in outlier detection:", e$message), type = "error")
      })
    })
  })
  
  # Add diagnostic output
  output$data_diagnostics <- renderPrint({
    req(merged_data())
    cat("Data summary:\n")
    print(summary(merged_data()))
    cat("\nAssays with all NA values:\n")
    print(merged_data() %>%
      group_by(Assay) %>%
      summarize(all_na = all(is.na(NPX))) %>%
      filter(all_na) %>%
      pull(Assay))
    cat("\nSamples with QC warnings:\n")
    print(merged_data() %>%
      filter(QC_Warning == "Warning") %>%
      distinct(SampleID) %>%
      pull(SampleID))
  })
}