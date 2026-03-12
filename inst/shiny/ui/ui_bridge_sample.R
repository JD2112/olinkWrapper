bridge_sample_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("link"), " Strategic Bridge Sample Selector")
      ),
      card_body(
        div(
          class = "row g-4",
          div(
            class = "col-md-5",
            div(
              class = "p-4 bg-light rounded-3 border h-100",
              h6(icon("filter"), " Quality Constraints", class = "mb-4 fw-bold"),
              numericInput("num_bridge_samples", "Target Number of Samples:", value = 8, min = 1),
              br(),
              numericInput("missing_freq", "Max Allowed Missing Frequency:", value = 0.1, min = 0, max = 1, step = 0.05),
              br(),
              actionButton("select_bridge_samples", " Identify Optimal Bridge Samples", 
                           class = "btn-primary w-100 py-2 mt-2", icon = icon("magic"))
            )
          ),
          div(
            class = "col-md-7",
            div(
              class = "p-4 border rounded-3 h-100",
              h6(icon("lightbulb"), " Recommendation Engine Results", class = "mb-3 fw-bold text-muted"),
              div(
                class = "bg-dark text-success p-3 rounded font-monospace small",
                style = "min-height: 200px;",
                verbatimTextOutput("bridge_sample_results")
              )
            )
          )
        ),
        
        br(),
        div(
          class = "alert alert-secondary border-0 mb-0",
          style = "background-color: #f1f5f9;",
          p(class = "small mb-0", 
            strong("Note: "), "Bridge samples are used to normalize and compare data between different study batches or panels. This tool selects the most stable and complete samples for this purpose.")
        )
      )
    )
  )
}