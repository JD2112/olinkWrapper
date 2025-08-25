ttest_ui <- function() {
  tagList(
    selectInput("ttest_var", "Grouping Variable", choices = NULL),
    radioButtons("ttest_var_type", "Variable Type", choices = c("Character", "Factor")),
    actionButton("run_ttest", "Run T-Test", class = "btn-primary"),
    DTOutput("ttest_output"),
    downloadButton("download_ttest", "Download Results", class = "btn-success")
  )
}