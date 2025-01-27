# server/server_boxplot.R
boxplot_server <- function(input, output, session, merged_data, anova_posthoc_results, ttest_results) {
  
  # Update input choices
  observe({
    req(merged_data())
    updateSelectInput(session, "boxplot_variable", choices = names(merged_data()))
    updateSelectizeInput(session, "boxplot_olinkid_list", choices = unique(merged_data()$OlinkID))
  })
  
  # Generate boxplot
  boxplot_data <- eventReactive(input$generate_boxplot, {
    req(merged_data(), input$boxplot_variable)
    
    # Remove control samples and assays, and handle NA values
    data <- merged_data() %>%
      filter(!str_detect(SampleID, regex("control|ctrl", ignore_case = TRUE))) %>%
      filter(!str_detect(Assay, regex("control|ctrl", ignore_case = TRUE))) %>%
      filter(!is.na(NPX)) %>%
      filter(!is.na(!!sym(input$boxplot_variable)))  # Remove NA values from the grouping variable
    
    # Convert the grouping variable to factor and ensure it's a character
    data[[input$boxplot_variable]] <- as.character(factor(data[[input$boxplot_variable]], exclude = NULL))
    
    # Prepare t-test or ANOVA results if selected
    stat_results <- if(input$boxplot_use_ttest) {
      req(ttest_results())
      ttest_results() %>%
        mutate(across(where(is.numeric), as.character))  # Convert numeric columns to character
    } else if(input$boxplot_use_posthoc) {
      req(anova_posthoc_results())
      anova_posthoc_results()
    } else {
      NULL
    }
    
    # Generate plot using olink_boxplot
    tryCatch({
      print("Generating boxplot...")
      print(paste("Grouping variable:", input$boxplot_variable))
      print(paste("Number of unique values in grouping variable:", length(unique(data[[input$boxplot_variable]]))))
      print("Unique values of grouping variable:")
      print(unique(data[[input$boxplot_variable]]))
      
      olink_boxplot(
        df = data,
        variable = input$boxplot_variable,
        olinkid_list = if(length(input$boxplot_olinkid_list) > 0) input$boxplot_olinkid_list else NULL,
        number_of_proteins_per_plot = input$boxplot_number_of_proteins,
        posthoc_results = if(input$boxplot_use_posthoc) stat_results else NULL,
        ttest_results = if(input$boxplot_use_ttest) stat_results else NULL
      )
    }, error = function(e) {
      print(paste("Error in olink_boxplot:", e$message))
      print("Data summary:")
      print(table(data[[input$boxplot_variable]]))
      NULL
    })
  })
  
  # Render boxplot
  output$boxplot <- renderPlot({
    plot_data <- boxplot_data()
    if (is.null(plot_data)) {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "Error generating boxplot. Please check your data and selections.", cex = 1.2)
      text(0, -0.1, "Check the console for more details.", cex = 0.8)
    } else if (is.list(plot_data) && length(plot_data) > 0) {
      print(plot_data[[1]])  # Use print() to display the ggplot object
    } else {
      plot(0, 0, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(0, 0, "No plot data available. Please check your selections.", cex = 1.2)
    }
  })

  # Download handler
  output$download_boxplot <- downloadHandler(
    filename = function() {
      paste("boxplot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      plot_data <- boxplot_data()
      if (!is.null(plot_data) && is.list(plot_data) && length(plot_data) > 0) {
        ggsave(file, plot = plot_data[[1]], device = "png", width = 10, height = 8)
      }
    }
  )
}