linear_regression_ui <- function() {
  tagList(
    h3("Linear Regression Analysis"),
    p("Test whether protein expression (NPX) predicts your selected outcome variable."),
    p(strong("Model:"), "DependentVariable ~ NPX + Covariates (run separately for each protein)"),
    
    uiOutput("dependent_var_ui"),

    numericInput("num_covariates", "Number of Covariates (optional)", value = 0, min = 0, max = 5),
    
    radioButtons("npx_or_zscore", "NPX value type:",
                 choices = c("Raw NPX", "Z-score"), selected = "Raw NPX", inline = TRUE),

    uiOutput("covariate_inputs"),

    actionButton("run_regression", "Run Linear Regression", class = "btn-primary"),

    hr(),
    DT::dataTableOutput("regression_results"),
    downloadButton("download_regression", "Download Results", class = "btn-success")
  )
}