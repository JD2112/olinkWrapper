normality_test_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("chart-line"), " Distribution & Normality Diagnostics")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Diagnostic Parameters",
            width = 300,
            selectInput("normality_protein", "Target Assay / Protein", 
                        choices = NULL),
            hr(),
            h6("Methodology", class = "fw-bold text-primary mb-3"),
            radioButtons("normality_test_type", NULL,
                         choices = c("Shapiro-Wilk Test" = "shapiro", 
                                   "Kolmogorov-Smirnov" = "ks")),
            br(),
            actionButton("run_normality", " Execute Diagnostics", 
                         class = "btn-primary w-100 py-2", icon = icon("microscope"))
          ),
          
          # Results Display
          div(
            class = "navset-container",
            navset_card_underline(
              title = "Analysis Output",
              nav_panel(
                title = tagList(icon("image"), " Visualization"),
                div(
                  class = "p-3",
                  layout_column_wrap(
                    width = 1/3,
                    gap = "1rem",
                    div(class = "border rounded p-2 bg-white", 
                        h6("Histogram", class="text-center mb-2"),
                        plotOutput("normality_hist", height = "300px")),
                    div(class = "border rounded p-2 bg-white", 
                        h6("Q-Q Plot", class="text-center mb-2"),
                        plotOutput("normality_qq", height = "300px")),
                    div(class = "border rounded p-2 bg-white", 
                        h6("Boxplot", class="text-center mb-2"),
                        plotOutput("normality_box", height = "300px"))
                  ),
                  br(),
                  downloadButton("download_normality_plots", " Export All Plots (PDF)", class = "btn-outline-success btn-sm")
                )
              ),
              nav_panel(
                title = tagList(icon("list-alt"), " Statistical Table"),
                div(
                  class = "p-4 bg-light rounded m-3 font-monospace border",
                  style = "min-height: 300px;",
                  verbatimTextOutput("normality_test_result")
                )
              )
            )
          )
        )
      )
    )
  )
}