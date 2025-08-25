pca_plot_ui <- function() {
  tagList(
    selectInput("pca_var", "Color Variable", choices = NULL),
    radioButtons("pca_var_type", "Variable Type", choices = c("Character", "Factor", "Numeric")),
    checkboxInput("label_pca", "Label Points"),
    actionButton("run_pca", "Run PCA", class = "btn-primary"),
    plotOutput("pca_plot"),
    downloadButton("download_pca", "Download Plot", class = "btn-success")
  )
}