lme_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("project-diagram"), " Linear Mixed Effects (LME) Modeling")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Model Parameters",
            width = 320,
            selectInput("lme_outcome_var", "Outcome Variable:", choices = NULL),
            selectInput("lme_fixed_effects", "Fixed Effects (IVs):", choices = NULL, multiple = TRUE),
            selectInput("lme_random_effects", "Random Effects (Groups):", choices = NULL, multiple = TRUE),
            hr(),
            actionButton("run_lme_model", " Fit LME Model", 
                         class = "btn-primary w-100", icon = icon("calculator"))
          ),
          
          # Results area
          div(
            class = "p-0",
            div(
              class = "p-3 font-monospace small bg-dark text-light rounded mb-3",
              style = "min-height: 150px;",
              verbatimTextOutput("lme_model_results")
            ),
            DTOutput("lme_results_table")
          )
        )
      )
    )
  )
}