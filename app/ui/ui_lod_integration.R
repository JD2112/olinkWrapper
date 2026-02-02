lod_integration_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("LOD Integration & Protein Filtering"),
          card_body(
            p("Integrate LOD information and identify proteins with many values below LOD."),
            actionButton("integrate_lod", "Integrate LOD Information", class = "btn-primary mb-3"),
            verbatimTextOutput("lod_integration_results"),
            hr(),
            h5("Proteins with >50% Below LOD:"),
            DT::dataTableOutput("below_lod_table"),
            actionButton("filter_lod_proteins", "Exclude these proteins from analysis", class = "btn-danger mt-3")
          )
        )
      )
    )
  )
}