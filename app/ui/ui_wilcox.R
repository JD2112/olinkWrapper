wilcox_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Mann-Whitney U Test (Wilcox Test)"),
          card_body("Mann-Whitney U Test",
            fluidRow(
              column(4,
                selectInput("mw_variable", "Variable:", choices = NULL),
                radioButtons("wilcox_var_type", "Variable Type", choices = c("Character", "Factor"))
              ),
              column(4,
                selectInput("alternative", "Alternative Hypothesis",
                  choices = c(
                    "Two Sided" = "two.sided",
                    "Greater" = "greater",
                    "Less" = "less"
                  ),
                  selected = "two.sided"
                )
              ),
              column(4,
                actionButton("run_mw_test", "Run Mann-Whitney U Test")                
              )
            ),
            DTOutput("wilcox_output"),
            downloadButton("download_wilcox", "Download Full Results")
          )
        )
      )
    )
  )
}