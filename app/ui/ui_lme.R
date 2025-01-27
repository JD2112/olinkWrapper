lme_ui <- function() {
  print("Rendering LME UI")
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Linear Mixed Effects Model"),
          card_body(
            selectInput("lme_outcome_var", "Outcome Variable:", choices = NULL),
            selectInput("lme_fixed_effects", "Fixed Effects:", choices = NULL, multiple = TRUE),
            selectInput("lme_random_effects", "Random Effects:", choices = NULL, multiple = TRUE),
            actionButton("run_lme_model", "Run Linear Mixed Effects Model"),
            verbatimTextOutput("lme_model_results"),
            DTOutput("lme_results_table")
          )
        )
      )
    )
  )
}