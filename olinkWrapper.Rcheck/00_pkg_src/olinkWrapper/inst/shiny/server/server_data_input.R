data_input_server <- function(input, output, session, merged_data, var_key_merged, npx_data_2) {
  observeEvent(input$merge_data, {
    withProgress(message = "Merging data...", value = 0, {
      req(input$npx_file, input$var_file)

      npx_data <- read_NPX(input$npx_file$datapath)
      var_data <- read_csv(input$var_file$datapath, col_types = cols())

      # Determine the merge key chosen by the user (default: SUBJID)
      merge_key <- input$merge_key
      if (is.null(merge_key) || merge_key == "") merge_key <- "SUBJID"

      # De-duplicate var_data on the chosen merge key
      if (merge_key %in% colnames(var_data)) {
        var_data <- var_data %>% distinct(across(all_of(merge_key)), .keep_all = TRUE)
        # Clean newline characters from the merge key column
        var_data[[merge_key]] <- gsub("\n", "", var_data[[merge_key]])
      }

      # Handle optional second NPX file for multi-panel / normalization / bridging
      if (!is.null(input$npx_file_2) && !is.null(input$npx_file_2$datapath)) {
        npx_data_2_raw <- read_NPX(input$npx_file_2$datapath)
        npx_data_2(npx_data_2_raw) # Store in reactive for normalization/bridge modules

        # Tag each dataset with a Project identifier for olink_normalization
        npx_data$Project <- "Dataset_1"
        npx_data_2_raw$Project <- "Dataset_2"

        # Row-bind both into a combined dataset
        npx_data <- bind_rows(npx_data, npx_data_2_raw)
        showNotification("Two NPX datasets loaded and combined.", type = "message")
      } else {
        npx_data_2(NULL)
      }

      # Merge logic depends on whether a Key file is provided
      if (!is.null(input$key_file) && !is.null(input$key_file$datapath)) {
        key_data <- read_csv(input$key_file$datapath, col_types = cols()) %>%
          distinct(SampleID, .keep_all = TRUE)
        key_data$SampleID <- as.character(key_data$SampleID)

        # Join NPX → Key (by SampleID) → Var (by user-selected merge_key)
        if (merge_key == "SampleID") {
          # Key file maps SampleID ↔ SampleID
          merged <- npx_data %>%
            left_join(key_data, by = "SampleID") %>%
            left_join(var_data, by = "SampleID")
        } else {
          # Key file maps SampleID ↔ SUBJID
          merged <- npx_data %>%
            left_join(key_data, by = "SampleID") %>%
            left_join(var_data, by = merge_key)
        }
      } else {
        # No key file: direct join NPX ↔ Var by merge_key
        if (merge_key == "SampleID") {
          merged <- npx_data %>%
            left_join(var_data, by = "SampleID")
        } else {
          # Create SUBJID = SampleID if SUBJID doesn't exist in NPX
          if (!merge_key %in% colnames(npx_data)) {
            npx_data[[merge_key]] <- npx_data$SampleID
          }
          merged <- npx_data %>%
            left_join(var_data, by = merge_key)
        }
      }

      merged_data(merged)

      updateSelectInput(session, "pca_var", choices = colnames(merged))
      updateSelectInput(session, "ttest_var", choices = colnames(merged))
      updateSelectInput(session, "anova_var", choices = colnames(merged))
      updateSelectInput(session, "volcano_var", choices = colnames(merged))
      updateSelectInput(session, "violin_group", choices = colnames(merged))
      updateSelectInput(session, "violin_protein", choices = unique(merged$Assay))
      updateSelectInput(session, "normality_protein", choices = unique(merged$Assay))

      showNotification(paste("Data merged successfully using", merge_key, "as join key."), type = "message")
      incProgress(1)
    })
  })

  observeEvent(input$merge_var_key, {
    withProgress(message = "Merging var and key data...", value = 0, {
      req(input$var_file)

      merge_key <- input$merge_key
      if (is.null(merge_key) || merge_key == "") merge_key <- "SUBJID"

      var_data <- read_csv(input$var_file$datapath, col_types = cols())

      # De-duplicate on merge key
      if (merge_key %in% colnames(var_data)) {
        var_data <- var_data %>% distinct(across(all_of(merge_key)), .keep_all = TRUE)
        var_data[[merge_key]] <- gsub("\n", "", var_data[[merge_key]])
      }

      if (!is.null(input$key_file)) {
        key_data <- read_csv(input$key_file$datapath, col_types = cols()) %>%
          distinct(SampleID, .keep_all = TRUE)
        key_data$SampleID <- as.character(key_data$SampleID)

        var_key_merged(var_data %>% left_join(key_data, by = merge_key))
      } else {
        showNotification("Key file is not provided. Cannot merge.", type = "warning")
        var_key_merged(var_data)
      }

      incProgress(1)
    })
  })
}
