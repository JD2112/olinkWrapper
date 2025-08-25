violin_plot_ui <- function() {
  tagList(
    selectInput("violin_protein", "Select Protein", choices = NULL),
    selectInput("violin_group", "Grouping Variable", choices = NULL),
    radioButtons("violin_var_type", "Variable Type", choices = c("Character", "Factor")),
    actionButton("run_violin", "Generate Violin Plot", class = "btn-primary"),
    plotOutput("violin_plot"),
    downloadButton("download_violin", "Download Plot", class = "btn-success")
  )
}