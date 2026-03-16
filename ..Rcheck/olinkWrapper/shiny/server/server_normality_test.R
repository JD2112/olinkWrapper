normality_test_server <- function(input, output, session, merged_data, analysis_log) {
  
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Update protein choices
  observe({
    req(merged_data())
    proteins <- unique(merged_data()$Assay)
    updateSelectInput(session, "normality_protein", 
                      choices = c("All Proteins", proteins))
  })
  
  # Reactive triggering for analysis results
  analysis_trigger <- eventReactive(input$run_normality, {
    req(merged_data(), input$normality_protein)
    
    withProgress(message = 'Calculating diagnostics...', value = 0, {
      if (input$normality_protein == "All Proteins") {
        data_for_test <- merged_data() %>% filter(!is.na(NPX))
        plot_title <- "All Proteins Distribution"
      } else {
        data_for_test <- merged_data() %>%
          filter(Assay == input$normality_protein, !is.na(NPX))
        plot_title <- paste("Distribution of", input$normality_protein)
      }
      
      incProgress(0.5, detail = "Preparing visualization")
      
      # Visualization for log
      p_hist <- ggplot(data_for_test, aes(x = NPX)) +
        geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.7) +
        geom_density(color = "red", size = 1) + theme_minimal() + labs(title = paste("Histogram:", plot_title))
      
      p_qq <- ggplot(data_for_test, aes(sample = NPX)) +
        stat_qq() + stat_qq_line(color = "red") + theme_minimal() + labs(title = paste("QQ-Plot:", plot_title))
      
      p_box <- ggplot(data_for_test, aes(y = NPX, x = 1)) +
        geom_boxplot(fill = "lightgreen", alpha = 0.7) + theme_minimal() + labs(title = paste("Boxplot:", plot_title))

      # Log analysis
      log_analysis(analysis_log, "Normality Test", 
                   paste("Assay:", input$normality_protein, "| Test:", input$normality_test_type),
                   plot = list(p_hist, p_qq, p_box))
      
      incProgress(0.5, detail = "Done")
      
      list(
        data = data_for_test,
        title = plot_title,
        test_type = input$normality_test_type,
        plots = list(p_hist, p_qq, p_box)
      )
    })
  })
  
  output$normality_hist <- renderPlot({
    req(analysis_trigger())
    analysis_trigger()$plots[[1]]
  })
  
  output$normality_qq <- renderPlot({
    req(analysis_trigger())
    analysis_trigger()$plots[[2]]
  })
  
  output$normality_box <- renderPlot({
    req(analysis_trigger())
    analysis_trigger()$plots[[3]]
  })
  
  output$normality_test_result <- renderPrint({
    req(analysis_trigger())
    res <- analysis_trigger()
    x <- res$data$NPX
    
    cat("--- Result for", res$test_type, "Test ---\n\n")
    
    if (length(x) < 3) {
      cat("Not enough data points for normality test.")
    } else {
      if (res$test_type == "shapiro") {
        if (length(x) > 5000) {
          cat("Note: Shapiro-Wilk test is limited to 5000 samples. Using a random sample of 5000.\n")
          shapiro.test(sample(x, 5000))
        } else {
          shapiro.test(x)
        }
      } else {
        ks_res <- ks.test(x, "pnorm", mean = mean(x, na.rm=TRUE), sd = sd(x, na.rm=TRUE))
        print(ks_res)
      }
    }
  })
  
  output$download_normality_plots <- downloadHandler(
    filename = function() { 
      paste0("olinkWrapper_", VERSION, "_NormalityPlots_", gsub(" ", "_", input$normality_protein), "_", format(Sys.Date(), "%Y%m%d"), ".pdf") 
    },
    content = function(file) {
      req(analysis_trigger())
      res <- analysis_trigger()
      pdf(file, width = 12, height = 6)
      print(res$plots[[1]])
      print(res$plots[[2]])
      print(res$plots[[3]])
      dev.off()
    }
  )
}