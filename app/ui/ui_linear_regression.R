linear_regression_ui <- function() {
  tagList(
    h3("Linear Regression Analysis"),

    radioButtons("npx_or_zscore", "NPX value type:",
                 choices = c("Raw NPX", "Z-score"), selected = "Raw NPX", inline = TRUE),

    # selectInput("dependent_var", "Select Dependent Variable",
    #             choices = NULL, selected = NULL),
    uiOutput("dependent_var_ui"),


    numericInput("num_covariates", "Number of Covariates", value = 0, min = 0, max = 5),

    uiOutput("covariate_inputs"),

    actionButton("run_regression", "Run Linear Regression"),

    hr(),
    DT::dataTableOutput("regression_results"),
    downloadButton("download_regression", "Download Results", class = "btn-success")
  )
}
