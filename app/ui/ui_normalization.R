normalization_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Data Normalization - (for more than one panel)"),
          card_body(
            selectInput("norm_method", "Normalization Method",
                        choices = c("Intensity", "Plate"),
                        selected = "Intensity"),
            selectInput("ref_sample", "Reference Sample",
                        choices = NULL),  # Will be updated in server
            actionButton("normalize", "Normalize Data", 
                         class = "btn-primary"),
            verbatimTextOutput("norm_summary")
          )
        )
      )
    )
  )
}