lod_integration_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("LOD Integration"),
          card_body(
            actionButton("integrate_lod", "Integrate LOD Information"),
            verbatimTextOutput("lod_integration_results")
          )
        )
      )
    )
  )
}