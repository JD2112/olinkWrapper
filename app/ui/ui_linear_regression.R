linear_regression_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("chart-line"), " Linear Regression Modeling (Per-Assay)"),
        downloadButton("download_regression", " Export Full Results", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Regression Settings",
            width = 320,
            p("Model: Outcome ~ NPX + [Covariates]", class = "text-muted small"),
            
            hr(),
            
            uiOutput("dependent_var_ui"),
            
            br(),
            h6(icon("database"), " NPX Transformation", class = "small fw-bold text-primary"),
            radioButtons("npx_or_zscore", NULL,
                         choices = c("Raw NPX", "Z-score"), selected = "Raw NPX", inline = TRUE),
            
            hr(),
            
            h6(icon("plus-circle"), " Add Covariates", class = "small fw-bold text-primary"),
            numericInput("linreg_num_covariates", "Count (max 5):", value = 0, min = 0, max = 5),
            uiOutput("linreg_covariate_inputs"),
            
            br(),
            actionButton("run_regression", " Calculate Regression", 
                         class = "btn-primary w-100 py-2", icon = icon("calculator"))
          ),
          
          # Results area
          div(
            class = "p-0",
            div(
              class = "alert alert-primary border-0 mb-3 small",
              icon("info-circle", class = "me-2"),
              "This module runs separate linear regression models for every protein in your dataset using the specified outcome."
            ),
            DT::dataTableOutput("regression_results")
          )
        )
      )
    )
  )
}