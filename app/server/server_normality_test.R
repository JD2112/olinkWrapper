normality_test_server <- function(input, output, session, merged_data) {
  
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
    
    if (input$normality_protein == "All Proteins") {
      data_for_test <- merged_data() %>% filter(!is.na(NPX))
      plot_title <- "All Proteins Distribution"
    } else {
      data_for_test <- merged_data() %>%
        filter(Assay == input$normality_protein, !is.na(NPX))
      plot_title <- paste("Distribution of", input$normality_protein)
    }
    
    list(
      data = data_for_test,
      title = plot_title,
      test_type = input$normality_test_type
    )
  })
  
  # Histogram
  output$normality_hist <- renderPlot({
    req(analysis_trigger())
    res <- analysis_trigger()
    ggplot(res$data, aes(x = NPX)) +
      geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.7) +
      geom_density(color = "red", size = 1) +
      theme_minimal() +
      labs(title = paste("Histogram:", res$title), x = "NPX", y = "Density")
  })
  
  # QQ-plot
  output$normality_qq <- renderPlot({
    req(analysis_trigger())
    res <- analysis_trigger()
    ggplot(res$data, aes(sample = NPX)) +
      stat_qq() +
      stat_qq_line(color = "red") +
      theme_minimal() +
      labs(title = paste("QQ-Plot:", res$title))
  })
  
  # Statistical Test Result
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
        # Kolmogorov-Smirnov test against normal distribution
        # ks.test(x, "pnorm", mean = mean(x, na.rm=TRUE), sd = sd(x, na.rm=TRUE))
        ks_res <- ks.test(x, "pnorm", mean = mean(x, na.rm=TRUE), sd = sd(x, na.rm=TRUE))
        print(ks_res)
      }
    }
  })
  
  output$download_normality_plots <- downloadHandler(
    filename = function() { 
      paste("normality_plots_", gsub(" ", "_", input$normality_protein), "_", Sys.Date(), ".pdf", sep="") 
    },
    content = function(file) {
      req(analysis_trigger())
      res <- analysis_trigger()
      pdf(file, width = 12, height = 6)
      
      p1 <- ggplot(res$data, aes(x = NPX)) +
        geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.7) +
        geom_density(color = "red", size = 1) +
        theme_minimal() + labs(title = paste("Histogram:", res$title))
        
      p2 <- ggplot(res$data, aes(sample = NPX)) +
        stat_qq() + stat_qq_line(color = "red") +
        theme_minimal() + labs(title = paste("QQ-Plot:", res$title))
      
      print(p1)
      print(p2)
      dev.off()
    }
  )
}