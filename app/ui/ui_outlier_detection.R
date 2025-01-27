outlier_detection_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Outlier Detection"),
          card_body(
            numericInput("outlier_threshold", "Outlier Threshold:", value = 2.5, step = 0.1),
            actionButton("detect_outliers", "Detect Outliers"),
            plotOutput("outlier_umap_plot")  # This line is crucial
          )
        )
      )
    )
  )
}