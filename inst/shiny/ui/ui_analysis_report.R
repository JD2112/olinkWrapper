analysis_report_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("file-export"), " Comprehensive Analysis Report")
      ),
      card_body(
        div(
          class = "text-center py-5",
          icon("file-pdf", class = "text-primary mb-4", style = "font-size: 5rem;"),
          h3("Generate Final Analysis Report", class = "fw-bold"),
          p("This report compiles all statistical analyses, visualizations, and exploratory steps performed during your current session into a single formatted PDF document.",
            class = "text-muted mx-auto", style = "max-width: 1200px;"
          ),
          br(),
          div(
            class = "d-flex justify-content-center gap-3",
            downloadButton(
              "download_analysis_report",
              label = tagList(icon("download"), " Download Complete Analysis Report (PDF)"),
              class = "btn-primary btn-lg px-4 py-3"
            )
          ),
          br(),
          hr(style = "width: 50%; margin: 2rem auto;"),
          h5("Report Features", class = "mb-3 text-secondary"),
          div(
            class = "row justify-content-center g-4",
            div(
              class = "col-md-3",
              tagList(icon("check-circle", class = "text-success"), p("Background Rationale"))
            ),
            div(
              class = "col-md-3",
              tagList(icon("image", class = "text-success"), p("All Visualizations"))
            ),
            div(
              class = "col-md-3",
              tagList(icon("table", class = "text-success"), p("Summary Tables"))
            )
          )
        ),

        # Log Preview
        hr(),
        h5("Session Activity Log", class = "mb-3"),
        p("The following steps will be included in your report:", class = "small text-muted"),
        div(
          class = "border rounded bg-light p-3",
          style = "max-height: 300px; overflow-y: auto;",
          tableOutput("analysis_log_preview")
        )
      )
    )
  )
}
