library(OlinkAnalyze)
library(ggplot2)
library(umap)
library(dplyr)
library(tidyr)
library(tibble)

outlier_detection_server <- function(input, output, session, merged_data, exclusion_log = NULL, analysis_log) {
  # Reactive values to store plots
  outlier_umap_rv <- reactiveVal(NULL)
  outlier_pca_rv <- reactiveVal(NULL)
  detected_outlier_ids <- reactiveVal(NULL)

  observeEvent(input$detect_outliers, {
    req(merged_data())

    withProgress(message = "Performing multivariate analysis...", value = 0, {
      tryCatch(
        {
          data <- merged_data()

          incProgress(0.1, detail = "Cleaning data")

          # Column Name Normalization
          if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
            data <- data %>% rename(SampleID = Sample_ID)
          }

          # Remove assays with all NA values
          valid_data <- data %>%
            group_by(Assay) %>%
            filter(!all(is.na(NPX))) %>%
            ungroup()

          # Prepare data for analysis
          # When two datasets are merged, there may be duplicate SampleID+Assay combos
          # Aggregate NPX by taking mean to prevent pivot_wider errors
          analysis_data <- valid_data %>%
            select(SampleID, Assay, NPX) %>%
            group_by(SampleID, Assay) %>%
            summarize(NPX = mean(NPX, na.rm = TRUE), .groups = "drop") %>%
            pivot_wider(names_from = Assay, values_from = NPX) %>%
            tibble::column_to_rownames("SampleID")

          # Impute missing values with column medians
          analysis_data_filled <- apply(analysis_data, 2, function(x) {
            if (all(is.na(x))) {
              return(rep(0, length(x)))
            }
            ifelse(is.na(x), median(x, na.rm = TRUE), x)
          })
          analysis_data_filled <- apply(analysis_data_filled, 2, as.numeric)

          incProgress(0.3, detail = "Running UMAP")

          # Run UMAP
          umap_result <- umap(analysis_data_filled)
          umap_coords <- as.data.frame(umap_result$layout)
          colnames(umap_coords) <- c("UMAP1", "UMAP2")
          umap_coords$SampleID <- rownames(analysis_data)

          incProgress(0.2, detail = "Running PCA")

          # Run PCA
          pca_result <- prcomp(analysis_data_filled, scale. = TRUE)
          pca_coords <- as.data.frame(pca_result$x[, 1:2])
          colnames(pca_coords) <- c("PC1", "PC2")
          pca_coords$SampleID <- rownames(analysis_data)

          incProgress(0.2, detail = "Identifying outliers")

          # Calculate distances based on UMAP (as originally implemented)
          distances <- as.matrix(dist(umap_coords[, c("UMAP1", "UMAP2")]))
          mean_distances <- colMeans(distances, na.rm = TRUE)

          threshold <- mean(mean_distances, na.rm = TRUE) +
            input$outlier_threshold * sd(mean_distances, na.rm = TRUE)

          is_outlier <- mean_distances > threshold
          umap_coords$outlier <- is_outlier
          pca_coords$outlier <- is_outlier

          # Store outlier IDs
          outlier_ids <- umap_coords$SampleID[is_outlier]
          detected_outlier_ids(outlier_ids)

          # Create Plots
          p_umap <- ggplot(umap_coords, aes(x = UMAP1, y = UMAP2, color = outlier)) +
            geom_point(alpha = 0.7, size = 2) +
            scale_color_manual(values = c("FALSE" = "#1e293b", "TRUE" = "#ef4444")) +
            labs(title = "UMAP: Outlier Detection", subtitle = paste("Threshold:", input$outlier_threshold, "SD"), color = "Is Outlier?") +
            theme_minimal()

          p_pca <- ggplot(pca_coords, aes(x = PC1, y = PC2, color = outlier)) +
            geom_point(alpha = 0.7, size = 2) +
            scale_color_manual(values = c("FALSE" = "#1e293b", "TRUE" = "#ef4444")) +
            labs(title = "PCA: Outlier Detection", subtitle = paste("Threshold:", input$outlier_threshold, "SD"), color = "Is Outlier?") +
            theme_minimal()

          # Store for download
          outlier_umap_rv(p_umap)
          outlier_pca_rv(p_pca)

          # Log analysis
          log_analysis(analysis_log, "Outlier Detection",
            paste("UMAP Threshold multiplier:", input$outlier_threshold, "SD"),
            plot = list(p_umap, p_pca)
          )

          # Render Plots
          output$outlier_umap_plot <- renderPlot(p_umap)
          output$outlier_pca_plot <- renderPlot(p_pca)

          output$outlier_exclusion_status <- renderPrint({
            if (length(outlier_ids) > 0) {
              cat("Detected", length(outlier_ids), "outlier samples:\n")
              cat(paste(outlier_ids, collapse = ", "), "\n")
            } else {
              cat("No outliers detected with current threshold.")
            }
          })

          incProgress(0.2, detail = "Done")
        },
        error = function(e) {
          showNotification(paste("Error in outlier detection:", e$message), type = "error")
        }
      )
    })
  })

  # Download Handlers
  # PDF Download Handlers
  output$download_outlier_umap_pdf <- downloadHandler(
    filename = function() {
      paste0("outlier_umap_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      req(outlier_umap_rv())
      ggsave(file, plot = outlier_umap_rv(), device = "pdf", width = 8, height = 6)
    }
  )

  output$download_outlier_pca_pdf <- downloadHandler(
    filename = function() {
      paste0("outlier_pca_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      req(outlier_pca_rv())
      ggsave(file, plot = outlier_pca_rv(), device = "pdf", width = 8, height = 6)
    }
  )

  # PNG Download Handlers
  output$download_outlier_umap_png <- downloadHandler(
    filename = function() {
      paste0("outlier_umap_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(outlier_umap_rv())
      ggsave(file, plot = outlier_umap_rv(), device = "png", width = 10, height = 8, dpi = 300)
    }
  )

  output$download_outlier_pca_png <- downloadHandler(
    filename = function() {
      paste0("outlier_pca_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(outlier_pca_rv())
      ggsave(file, plot = outlier_pca_rv(), device = "png", width = 10, height = 8, dpi = 300)
    }
  )

  observeEvent(input$exclude_outliers, {
    req(merged_data(), detected_outlier_ids())

    outliers_to_remove <- detected_outlier_ids()
    if (length(outliers_to_remove) == 0) {
      showNotification("No outliers found to exclude.", type = "message")
      return()
    }

    withProgress(message = "Excluding outliers...", value = 0, {
      data <- merged_data()
      # Normalize here too
      if (!"SampleID" %in% colnames(data) && "Sample_ID" %in% colnames(data)) {
        data <- data %>% rename(SampleID = Sample_ID)
      }

      n_samples_before <- length(unique(data$SampleID))
      n_proteins_before <- length(unique(data$Assay))
      n_rows_before <- nrow(data)

      new_data <- data %>%
        filter(!(SampleID %in% outliers_to_remove))

      merged_data(new_data)
      showNotification(paste("Excluded", length(outliers_to_remove), "outlier samples."), type = "message")

      # Append to shared exclusion log
      if (!is.null(exclusion_log)) {
        current_log <- exclusion_log()
        current_log[[length(current_log) + 1]] <- list(
          step = "B. Preprocessing > 4. Outlier Detection – Exclude outlier samples",
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          description = paste(
            "Removed", length(outliers_to_remove),
            "sample(s) identified as outliers via UMAP-based distance analysis.",
            "Outlier threshold:", paste0("mean + ", input$outlier_threshold, " x SD of pairwise distances.")
          ),
          samples_excluded = outliers_to_remove,
          proteins_excluded = character(0),
          before = list(samples = n_samples_before, proteins = n_proteins_before, rows = n_rows_before),
          after = list(
            samples = length(unique(new_data$SampleID)),
            proteins = length(unique(new_data$Assay)),
            rows = nrow(new_data)
          ),
          notes = paste("UMAP outlier threshold multiplier used:", input$outlier_threshold)
        )
        exclusion_log(current_log)
      }

      # Reset
      detected_outlier_ids(NULL)
      output$outlier_exclusion_status <- renderPrint(cat("Outliers excluded."))

      incProgress(1)
    })
  })
}
