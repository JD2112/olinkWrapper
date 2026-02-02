normality_test_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 4,
        card(
          card_header("Normality Test Settings"),
          card_body(
            selectInput("normality_protein", "Select Protein (or 'All Proteins')", 
                        choices = NULL),
            radioButtons("normality_test_type", "Select Statistical Test",
                         choices = c("Shapiro-Wilk" = "shapiro", 
                                   "Kolmogorov-Smirnov" = "ks")),
            actionButton("run_normality", "Run Analysis", class = "btn-primary w-100")
          )
        )
      ),
      column(
        width = 8,
        card(
          card_header("Results"),
          card_body(
            navset_tab(
              nav_panel("Plots", 
                layout_column_wrap(
                  width = 1/2,
                  plotOutput("normality_hist"),
                  plotOutput("normality_qq")
                ),
                downloadButton("download_normality_plots", "Download Plots", class = "btn-success mt-2")
              ),
              nav_panel("Statistical Test", 
                verbatimTextOutput("normality_test_result")
              )
            )
          )
        )
      )
    )
  )
}