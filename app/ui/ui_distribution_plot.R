distribution_plot_ui <- function() {
  tagList(
    fluidRow(
      column(6,
        selectInput("dist_color_variable", "Color Variable:", choices = NULL)
      ),
      column(6,
        actionButton("generate_dist_plot", "Generate Distribution Plot")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("distribution_plot")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_dist_plot", "Download Plot")
      )
    )
  )
}