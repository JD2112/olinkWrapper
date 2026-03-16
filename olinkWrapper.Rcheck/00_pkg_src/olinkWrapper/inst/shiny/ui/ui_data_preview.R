data_preview_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          class = "shadow-sm border-0",
          card_header(
            class = "bg-transparent border-0 pt-4",
            h4(icon("database"), " Data Management", style = "color: var(--primary); font-weight: 600;")
          ),
          card_body(
            layout_column_wrap(
              width = 1/2,
              gap = "1.5rem",
              # Export Sub-section
              div(
                class = "p-3 rounded-3",
                style = "background-color: #f8fafc; border: 1px solid #e2e8f0;",
                h6(icon("download"), " Export Options", class = "mb-3 text-muted"),
                div(
                  class = "d-grid gap-2",
                  downloadButton("download_full_data", " Full Dataset", class = "btn-outline-primary mb-2"),
                  downloadButton("download_var_key_data", " Var-Key Data", class = "btn-outline-primary")
                )
              ),
              # Filtering Sub-section
              div(
                class = "p-3 rounded-3",
                style = "background-color: #fff1f2; border: 1px solid #fecdd3;",
                h6(icon("filter"), " Quality Control", class = "mb-3 text-danger"),
                actionButton("filter_qc_warnings", " Exclude QC Warnings", class = "btn-danger w-100 mb-3", icon = icon("trash-alt")),
                tags$div(
                  style = "height: 80px; overflow-y: auto; background: white; border-radius: 8px; padding: 8px; font-size: 0.8rem; border: 1px solid #fecdd3;",
                  verbatimTextOutput("qc_filter_status")
                )
              )
            )
          )
        )
      )
    ),
    br(),
    card(
      class = "shadow-sm border-0",
      card_header(
        class = "bg-transparent border-0 pt-4",
        h4(icon("table"), " Dataset Explorer", style = "color: var(--primary); font-weight: 600;")
      ),
      card_body(
        DTOutput("data_preview")
      )
    )
  )
}