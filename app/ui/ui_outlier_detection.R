outlier_detection_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Outlier Detection & Exclusion"),
          card_body(
            p("Detect outliers using UMAP distances. You can exclude outliers after detection."),
            numericInput("outlier_threshold", "Outlier Threshold (SD):", value = 2.5, step = 0.1),
            actionButton("detect_outliers", "Detect Outliers", class = "btn-primary mb-3"),
            plotOutput("outlier_umap_plot"),
            hr(),
            h5("Outlier Exclusion:"),
            actionButton("exclude_outliers", "Exclude detected outliers from analysis", class = "btn-danger"),
            verbatimTextOutput("outlier_exclusion_status")
          )
        )
      )
    )
  )
}