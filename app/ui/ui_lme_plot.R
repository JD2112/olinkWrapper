lme_plot_ui <- function() {
  tagList(
    fluidRow(
      column(4,
        selectizeInput("lme_plot_olinkid_list", "Select OlinkIDs:", choices = NULL, multiple = TRUE)
      ),
      column(4,
        selectizeInput("lme_plot_variable", "Variables:", choices = NULL, multiple = TRUE)
      ),
      column(4,
        selectInput("lme_plot_random", "Random Effect:", choices = NULL)
      )
    ),
    fluidRow(
      column(4,
        selectInput("lme_plot_x_axis_variable", "X-axis Variable:", choices = NULL)
      ),
      column(4,
        selectInput("lme_plot_col_variable", "Color Variable:", choices = NULL)
      ),
      column(4,
        actionButton("generate_lme_plot", "Generate LME Plot")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("lme_plot_output")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_lme_plot", "Download Plot")
      )
    )
  )
}