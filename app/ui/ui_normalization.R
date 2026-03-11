normalization_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("balance-scale-right"), " Multi-Panel Normalization")
      ),
      card_body(
        div(
          class = "row align-items-center",
          div(
            class = "col-md-5",
            div(
              class = "p-4 bg-light rounded-3 border",
              h6(icon("sliders-h"), " Normalization Parameters", class = "mb-3 fw-bold"),
              selectInput("norm_method", "Select Method",
                choices = c("Intensity" = "Intensity", "Plate" = "Plate"),
                selected = "Intensity"
              ),
              selectInput("ref_sample", "Reference Sample ID",
                choices = NULL
              ),
              br(),
              actionButton("normalize", " Run Normalization",
                class = "btn-primary w-100 py-2",
                icon = icon("play")
              )
            )
          ),
          div(
            class = "col-md-7",
            div(
              class = "p-4 border rounded-3 h-100",
              style = "min-height: 200px;",
              h6(icon("clipboard-list"), " Process Summary", class = "mb-3 fw-bold text-muted"),
              verbatimTextOutput("norm_summary")
            )
          )
        ),
        br(),
        div(
          class = "alert alert-info border-0 shadow-sm d-flex align-items-center mb-0",
          icon("info-circle", class = "me-3 fs-3"),
          div(
            p(class = "mb-0 fw-bold", "About Normalization"),
            p(class = "mb-0 small", "Normalization is essential when combining multiple Olink panels or plates. Upload a second NPX file in the sidebar to enable automatic two-dataset bridge normalization. For single-panel data, select a reference sample above.")
          )
        )
      )
    )
  )
}
