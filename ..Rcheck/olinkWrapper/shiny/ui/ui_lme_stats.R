lme_stats_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("brain"), " Linear Mixed Effects (LME) Modeling")
      ),
      card_body(
        div(
          class = "p-4 bg-light rounded-3 border mb-4",
          h6(icon("cogs"), " Model Specification", class = "mb-4 fw-bold"),
          layout_column_wrap(
            width = 1/3,
            selectInput("lmer_outcome", "Outcome Variable (DV):", choices = NULL),
            selectInput("lmer_fixed", "Fixed Effects (IV):", choices = NULL, multiple = TRUE),
            selectInput("lmer_random", "Random Effects (Groups):", choices = NULL, multiple = TRUE)
          ),
          br(),
          actionButton("run_lmer", " Fit Mixed Model", class = "btn-primary px-4", icon = icon("calculator"))
        ),
        
        navset_card_underline(
          title = "Analysis Output",
          nav_panel(
            title = tagList(icon("terminal"), " Model Summary"),
            div(
              class = "p-3 font-monospace small bg-dark text-light rounded",
              style = "min-height: 200px;",
              verbatimTextOutput("lmer_results")
            )
          ),
          nav_panel(
            title = tagList(icon("table"), " Predicted Values Table"),
            div(
              class = "p-0",
              DTOutput("lme_npx_table")
            )
          )
        )
      )
    )
  )
}