volcano_plot_ui <- function() {
  tagList(
    radioButtons("volcano_plot_type", "Select Analysis Type", 
                 choices = c("T-test" = "ttest", "ANOVA" = "anova")),
    actionButton("run_volcano", "Generate Volcano Plot", class = "btn-primary"),
    plotOutput("volcano_plot"),
    downloadButton("download_volcano", "Download Plot", class = "btn-success")
  )
}