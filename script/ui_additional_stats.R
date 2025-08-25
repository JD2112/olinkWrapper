additional_stats_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Additional Statistical Tests"),
          card_body(
            tabsetPanel(
              tabPanel("Mann-Whitney U Test",
                       selectInput("mw_variable", "Variable:", choices = NULL),
                       selectInput("mw_group1", "Group 1:", choices = NULL),
                       selectInput("mw_group2", "Group 2:", choices = NULL),
                       actionButton("run_mw_test", "Run Mann-Whitney U Test"),
                       verbatimTextOutput("mw_results")
              ),
              tabPanel("Linear Mixed Effects Model",
                       selectInput("lmer_outcome", "Outcome Variable:", choices = NULL),
                       selectInput("lmer_fixed", "Fixed Effects:", choices = NULL, multiple = TRUE),
                       selectInput("lmer_random", "Random Effects:", choices = NULL, multiple = TRUE),
                       actionButton("run_lmer", "Run Linear Mixed Effects Model"),
                       verbatimTextOutput("lmer_results"),
                       DTOutput("lme_npx_table")
              ),
              tabPanel("Non-parametric Tests",
                       radioButtons("nonparam_test", "Test Type:", 
                                    choices = c("Kruskal-Wallis" = "kruskal", "Friedman" = "friedman")),
                       selectInput("nonparam_variable", "Variable:", choices = NULL),
                       selectInput("nonparam_group", "Grouping Variable:", choices = NULL),
                       actionButton("run_nonparam_test", "Run Non-parametric Test"),
                       verbatimTextOutput("nonparam_results")
              )
            )
          )
        )
      )
    )
  )
}