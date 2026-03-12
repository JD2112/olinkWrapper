outlier_detection_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("user-secret"), " Advanced Outlier Detection (UMAP-based)")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Detection Logic",
            width = 300,
            p("Identify anomalous samples based on их positioning in multivariate UMAP space.", class = "small text-muted mb-4"),
            numericInput("outlier_threshold", "Standard Deviation Threshold:", value = 2.5, step = 0.1, min = 1),
            br(),
            actionButton("detect_outliers", " Run Analysis", class = "btn-primary w-100", icon = icon("search")),
            hr(),
            h6("Exclusion Actions", class = "text-danger"),
            actionButton("exclude_outliers", " Purge Outliers", class = "btn-danger w-100", icon = icon("trash-alt")),
            br(), br(),
            div(
              class = "bg-light p-2 rounded small",
              verbatimTextOutput("outlier_exclusion_status")
            )
          ),
          
          # Main Plot Area
          div(
            class = "p-3 bg-white rounded-3 border",
            navset_card_underline(
              title = "Diagnostic Plots",
              nav_panel(
                "UMAP Projection",
                plotOutput("outlier_umap_plot", height = "500px"),
                br(),
                 downloadButton("download_outlier_umap_pdf", " Save UMAP (PDF)", class = "btn-outline-primary btn-sm"),
                 downloadButton("download_outlier_umap_png", " Save UMAP (PNG)", class = "btn-outline-success btn-sm")
              ),
              nav_panel(
                "PCA Projection",
                plotOutput("outlier_pca_plot", height = "500px"),
                br(),
                 downloadButton("download_outlier_pca_pdf", " Save PCA (PDF)", class = "btn-outline-primary btn-sm"),
                 downloadButton("download_outlier_pca_png", " Save PCA (PNG)", class = "btn-outline-success btn-sm")
              )
            )
          )
        )
      )
    )
  )
}