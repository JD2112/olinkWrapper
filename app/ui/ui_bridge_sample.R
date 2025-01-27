bridge_sample_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Bridge Sample Selection"),
          card_body(
            fluidRow(
              column(4,
                numericInput("num_bridge_samples", "Number of Bridge Samples:", value = 8, min = 1),
                ),
              column(4,
                numericInput("missing_freq", "Sample Missing Frequency:", value = 0.1, min = 0.1),
                ),
              column(4,
                actionButton("select_bridge_samples", "Select Bridge Samples"),
                )
            ),                        
            verbatimTextOutput("bridge_sample_results")
          )
        )
      )
    )
  )
}