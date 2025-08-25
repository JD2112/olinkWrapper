library(shiny)
library(DT)

pathway_enrichment_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Pathway Enrichment Analysis"),
          card_body(
            uiOutput("pathway_enrichment_content")
          )
        )
      )
    )
  )
}