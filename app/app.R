library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
library(OlinkAnalyze)
library(readr)
library(writexl)
library(gridExtra)

ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "flatly"),

  
  
  tags$head(
    tags$style(HTML("
      body {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
      }
      .footer {
        margin-top: auto;
      }
      .footer-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .footer-section {
        flex: 1;
        text-align: center;
      }
      .footer-left {
        text-align: left;
      }
      .footer-right {
        text-align: right;
      }
      .initially-hidden {
        display: none;
      }
    "))
  ),
 # Title
  h1("ShinyOlink: Shiny Interface for Olink Data Analysis", class = "text-center mb-4"),
  
  sidebar = sidebar(
    title = "Data Input",
    fileInput("npx_file", "Upload NPX Data (CSV)", accept = c(".csv")),
    fileInput("key_file", "Upload Key File (CSV)", accept = c(".csv")),
    fileInput("var_file", "Upload Variables File (CSV)", accept = c(".csv")),
    actionButton("merge_data", "Merge Data", class = "btn-primary"),
    HTML("<hr> <a href='ShinyOlink.txt' target='_blank'> <i class='fa fa-download'> </i> HOW TO USE</a>")
  ),
  
  navset_tab(
    nav_panel("Data Preview", DTOutput("data_preview")),
    nav_panel("Descriptive Statistics", 
              actionButton("run_desc_stats", "Run Descriptive Statistics", class = "btn-primary"),
              DTOutput("desc_stats_output")),
    nav_panel("Normality Test", 
              selectInput("normality_protein", "Select Protein", choices = NULL),
              actionButton("run_normality", "Run Normality Test", class = "btn-primary"),
              plotOutput("normality_plot"),
              verbatimTextOutput("normality_test_result"),
              downloadButton("download_normality_plot", "Download Plot", class = "btn-success")),
    nav_panel("PCA Plot", 
              selectInput("pca_var", "Color Variable", choices = NULL),
              radioButtons("pca_var_type", "Variable Type", choices = c("Character", "Factor", "Numeric")),
              checkboxInput("label_pca", "Label Points"),
              actionButton("run_pca", "Run PCA", class = "btn-primary"),
              plotOutput("pca_plot"),
              downloadButton("download_pca", "Download Plot", class = "btn-success")),
    nav_panel("T-Test", 
              selectInput("ttest_var", "Grouping Variable", choices = NULL),
              radioButtons("ttest_var_type", "Variable Type", choices = c("Character", "Factor")),
              actionButton("run_ttest", "Run T-Test", class = "btn-primary"),
              DTOutput("ttest_output"),
              downloadButton("download_ttest", "Download Results", class = "btn-success")),
    nav_panel("ANOVA", 
              selectInput("anova_var", "Grouping Variable", choices = NULL),
              radioButtons("anova_var_type", "Variable Type", choices = c("Character", "Factor")),
              selectInput("num_covariates", "Number of Covariates", choices = 0:4),
              uiOutput("covariate_inputs"),
              actionButton("run_anova", "Run ANOVA", class = "btn-primary"),
              DTOutput("anova_output"),
              downloadButton("download_anova", "Download Results", class = "btn-success")),
    nav_panel("Volcano Plot", 
              selectInput("volcano_var", "Grouping Variable", choices = NULL),
              radioButtons("volcano_var_type", "Variable Type", choices = c("Character", "Factor")),
              actionButton("run_volcano", "Generate Volcano Plot", class = "btn-primary"),
              plotOutput("volcano_plot"),
              downloadButton("download_volcano", "Download Plot", class = "btn-success")),
    nav_panel("Violin Plot", 
              selectInput("violin_protein", "Select Protein", choices = NULL),
              selectInput("violin_group", "Grouping Variable", choices = NULL),
              radioButtons("violin_var_type", "Variable Type", choices = c("Character", "Factor")),
              actionButton("run_violin", "Generate Violin Plot", class = "btn-primary"),
              plotOutput("violin_plot"),
              downloadButton("download_violin", "Download Plot", class = "btn-success"))
  ),
    # Footer
  div(
    class = "footer mt-auto py-3 bg-light",
    div(
      class = "container footer-content",
      div(
        class = "footer-section footer-left",
        "©2024, Jyotirmoy Das, Bioinformactics Core Facility, Linköping University"
      ),
      div(
        class = "footer-section",
        a("GitHub", href = "https://github.com/JD2112/OlinkShiny", target = "_blank")
      ),
      div(
        class = "footer-section footer-right",
        "Version 1.0"
      )
    )
  )
)

server <- function(input, output, session) {
  options(shiny.maxRequestSize=1000000*1024^2)
  # Reactive values to store data and results
  merged_data <- reactiveVal()
  ttest_results <- reactiveVal()
  anova_results <- reactiveVal()
  
  # Merge data when the button is clicked
  observeEvent(input$merge_data, {
    withProgress(message = 'Merging data...', value = 0, {
    req(input$npx_file, input$key_file, input$var_file)
    
    npx_data <- read_NPX(input$npx_file$datapath)
    key_data <- read_csv(input$key_file$datapath, col_types = cols()) %>%
      distinct(SampleID, .keep_all = TRUE)
    var_data <- read_csv(input$var_file$datapath, col_types = cols()) %>%
      distinct(SUBJID, .keep_all = TRUE)
    
    key_data$SampleID <- as.character(key_data$SampleID)
    if("SUBJID" %in% colnames(var_data)) {
      var_data$SUBJID <- gsub("\n", "", var_data$SUBJID)
    }
    
    merged <- npx_data %>%
      left_join(key_data, by = "SampleID") %>%
      left_join(var_data, by = "SUBJID")
    
    merged_data(merged)
    
    updateSelectInput(session, "pca_var", choices = colnames(merged))
    updateSelectInput(session, "ttest_var", choices = colnames(merged))
    updateSelectInput(session, "anova_var", choices = colnames(merged))
    updateSelectInput(session, "volcano_var", choices = colnames(merged))
    updateSelectInput(session, "violin_group", choices = colnames(merged))
    updateSelectInput(session, "violin_protein", choices = unique(merged$Assay))
    updateSelectInput(session, "normality_protein", choices = unique(merged$Assay))

    incProgress(1)
    })
  })
  
  # Data Preview
  output$data_preview <- renderDT({
    req(merged_data())
    datatable(head(merged_data(), 100), options = list(scrollX = TRUE))
  })
  
  # Descriptive Statistics
  observeEvent(input$run_desc_stats, {
    withProgress(message = 'Calculating descriptive statistics...', value = 0, {

    req(merged_data())
    output$desc_stats_output <- renderDT({
      summary_data <- summary(merged_data())
      summary_df <- as.data.frame(do.call(rbind, lapply(summary_data, function(x) as.list(x))))
      datatable(summary_df, options = list(scrollX = TRUE))
    })
    
    incProgress(1)
    })
  })
  
  # Normality Test
  observeEvent(input$run_normality, {
    withProgress(message = 'Running normality test...', value = 0, {

    req(merged_data(), input$normality_protein)
    data_for_test <- merged_data() %>%
      filter(Assay == input$normality_protein)
    
    output$normality_plot <- renderPlot({
      ggplot(data_for_test, aes(x = NPX)) +
        geom_histogram(bins = 30, fill = "skyblue", color = "black") +
        ggtitle(paste("Distribution of", input$normality_protein)) +
        theme_minimal()
    })
    
    output$normality_test_result <- renderPrint({
      shapiro.test(data_for_test$NPX)
    })
    incProgress(1)
  })
  })
  
  # PCA Plot
  observeEvent(input$run_pca, {
    withProgress(message = 'Generating PCA plot...', value = 0, {

    req(merged_data(), input$pca_var)
    data_for_pca <- merged_data()
    
    if (input$pca_var_type == "Factor") {
      data_for_pca[[input$pca_var]] <- as.factor(data_for_pca[[input$pca_var]])
    } else if (input$pca_var_type == "Numeric") {
      data_for_pca[[input$pca_var]] <- as.numeric(data_for_pca[[input$pca_var]])
    } else {
      data_for_pca[[input$pca_var]] <- as.character(data_for_pca[[input$pca_var]])
    }
    
    output$pca_plot <- renderPlot({
      p <- olink_pca_plot(data_for_pca, color_g = input$pca_var)
      
      if (input$label_pca) {
        p <- p + ggrepel::geom_text_repel(aes(label = SampleID))
      }
      
      p
    })
    incProgress(1)
    })
  })
  
  # T-Test
observeEvent(input$run_ttest, {
  withProgress(message = 'Running T-Test...', value = 0, {
    tryCatch({
      req(merged_data(), input$ttest_var)
      data_for_test <- merged_data()
      
      if (input$ttest_var_type == "Factor") {
        data_for_test[[input$ttest_var]] <- as.factor(data_for_test[[input$ttest_var]])
      } else {
        data_for_test[[input$ttest_var]] <- as.character(data_for_test[[input$ttest_var]])
      }
      
      results <- olink_ttest(data_for_test, variable = input$ttest_var)
      ttest_results(results)  # Store results in reactive value
      
      output$ttest_output <- renderDT({
        datatable(results, options = list(scrollX = TRUE))
      })
      
      incProgress(1)
    }, error = function(e) {
      showNotification(paste("Error in T-Test:", e$message), type = "error")
    })
  })
})
  
  # ANOVA
  output$covariate_inputs <- renderUI({
    req(input$num_covariates)
    num_covariates <- as.numeric(input$num_covariates)
    lapply(1:num_covariates, function(i) {
      selectInput(paste0("covariate", i), paste("Select Covariate", i), 
                  choices = c("None", colnames(merged_data())))
    })
  })
  
  observeEvent(input$run_anova, {
    withProgress(message = 'Running ANOVA...', value = 0, {

    req(merged_data(), input$anova_var)
    data_for_test <- merged_data()
    
    if (input$anova_var_type == "Factor") {
      data_for_test[[input$anova_var]] <- as.factor(data_for_test[[input$anova_var]])
    } else {
      data_for_test[[input$anova_var]] <- as.character(data_for_test[[input$anova_var]])
    }
    
    covariates <- c()
    for(i in 1:as.numeric(input$num_covariates)) {
      cov <- input[[paste0("covariate", i)]]
      if(!is.null(cov) && cov != "None") {
        covariates <- c(covariates, cov)
      }
    }
    
    if(length(covariates) == 0) {
      results <- olink_anova(data_for_test, variable = input$anova_var)
    } else {
      results <- olink_anova(data_for_test, variable = input$anova_var, covariates = covariates)
    }
    
    anova_results(results)  # Store results in reactive value
    
    output$anova_output <- renderDT({
      datatable(results, options = list(scrollX = TRUE))
    })
    incProgress(1)
    })
  })
  
  # Volcano Plot
  observeEvent(input$run_volcano, {
    withProgress(message = 'Generating Volcano plot...', value = 0, {

    req(merged_data(), input$volcano_var)
    data_for_test <- merged_data()
    
    if (input$volcano_var_type == "Factor") {
      data_for_test[[input$volcano_var]] <- as.factor(data_for_test[[input$volcano_var]])
    } else {
      data_for_test[[input$volcano_var]] <- as.character(data_for_test[[input$volcano_var]])
    }
    
    if (length(unique(data_for_test[[input$volcano_var]])) == 2) {
      results <- olink_ttest(data_for_test, variable = input$volcano_var)
    } else {
      results <- olink_anova(data_for_test, variable = input$volcano_var)
      results <- results %>% mutate(estimate = statistic)
    }
    
    output$volcano_plot <- renderPlot({
      olink_volcano_plot(results)
    })
    incProgress(1)
    })
  })
  
  # Violin Plot
  observeEvent(input$run_violin, {
    withProgress(message = 'Generating Violin plot...', value = 0, {

    req(merged_data(), input$violin_protein, input$violin_group)
    data_for_plot <- merged_data()
    
    if (input$violin_var_type == "Factor") {
      data_for_plot[[input$violin_group]] <- as.factor(data_for_plot[[input$violin_group]])
    } else {
      data_for_plot[[input$violin_group]] <- as.character(data_for_plot[[input$violin_group]])
    }
    
    plot_data <- data_for_plot %>%
      filter(Assay == input$violin_protein)
    
    output$violin_plot <- renderPlot({
      ggplot(plot_data, aes(x = !!sym(input$violin_group), y = NPX, fill = !!sym(input$violin_group))) +
        geom_violin(trim = FALSE) +
        geom_boxplot(width = 0.1, fill = "white") +
        labs(title = paste("Violin Plot for", input$violin_protein),
             x = input$violin_group,
             y = "NPX Value") +
        theme_minimal() +
        theme(legend.position = "none")
    })
    incProgress(1)
    })
  })
  
  # Download handlers
  output$download_normality_plot <- downloadHandler(
    filename = function() { paste("normality_plot_", input$normality_protein, "_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
  
  output$download_pca <- downloadHandler(
    filename = function() { paste("pca_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
  
  output$download_ttest <- downloadHandler(
    filename = function() { paste("ttest_results_", Sys.Date(), ".xlsx", sep="") },
    content = function(file) {
      req(ttest_results())
      write_xlsx(list(ttest_results = ttest_results()), file)
    }
  )
  
  output$download_anova <- downloadHandler(
    filename = function() { paste("anova_results_", Sys.Date(), ".xlsx", sep="") },
    content = function(file) {
      req(anova_results())
      write_xlsx(list(anova_results = anova_results()), file)
    }
  )
  
  output$download_volcano <- downloadHandler(
    filename = function() { paste("volcano_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
  
  output$download_violin <- downloadHandler(
    filename = function() { paste("violin_plot_", Sys.Date(), ".png", sep="") },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 10, height = 8)
    }
  )
}

shinyApp(ui, server)