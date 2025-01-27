lme_stats_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Linear Mixed Effects Model"),
          card_body(
                    fluidRow(
              column(4,
                selectInput("lmer_outcome", "Outcome Variable:", choices = NULL)
              ),
              column(4,
                selectInput("lmer_fixed", "Fixed Effects:", choices = NULL, multiple = TRUE)
              ),
              column(4,
                selectInput("lmer_random", "Random Effects:", choices = NULL, multiple = TRUE)              )
            ),
            fluidRow(
              column(12,
                actionButton("run_lmer", "Run Linear Mixed Effects Model")
              )
            ),
            verbatimTextOutput("lmer_results"),
            DTOutput("lme_npx_table")
            # ,
            # downloadButton("download_lme", "Download Full Results")
          )        
          )
        )
      )
    )
}