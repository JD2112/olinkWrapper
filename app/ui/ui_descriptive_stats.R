descriptive_stats_ui <- function() {
  tagList(
    actionButton("run_desc_stats", "Run Descriptive Statistics", class = "btn-primary"),
    DTOutput("desc_stats_output")
  )
}