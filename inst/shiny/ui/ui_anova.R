anova_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("vial"), " Multi-group Comparison: ANOVA"),
        downloadButton("download_anova", " Export CSV", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Model Specification",
            width = 320,
            selectInput("anova_var", "Primary Variable (Factor)", choices = NULL),
            radioButtons("anova_var_type", "Variable Type", 
                         choices = c("Character", "Factor", "Numeric"),
                         selected = "Factor"),
            hr(),
            selectInput("anova_num_covariates", "Number of Covariates", choices = 0:4),
            uiOutput("anova_covariate_inputs"),
            hr(),
            p(class = "small text-muted", 
              "Performs Analysis of Variance (ANOVA) to detect significant differences across multiple groups, with support for covariates."),
            actionButton("run_anova", " Compute ANOVA", 
                         class = "btn-primary w-100 mt-2", 
                         icon = icon("calculator"))
          ),
          
          # Output table
          div(
            class = "p-0 bg-white rounded-3",
            DTOutput("anova_output")
          )
        )
      )
    )
  )
}