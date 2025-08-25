normality_test_ui <- function() {
  tagList(
    selectInput("normality_protein", "Select Protein", choices = NULL),
    actionButton("run_normality", "Run Normality Test", class = "btn-primary"),
    plotOutput("normality_plot"),
    verbatimTextOutput("normality_test_result"),
    downloadButton("download_normality_plot", "Download Plot", class = "btn-success")
  )
}