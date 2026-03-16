library(shiny)
library(DT)

pathway_enrichment_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("project-diagram"), " Pathway Enrichment Studio")
      ),
      card_body(
        class = "p-4",
        div(
          class = "alert alert-info border-0 mb-4 d-flex align-items-center",
          icon("info-circle", class = "me-3 fs-3"),
          div(
            p(class = "mb-0 fw-bold", "About Biological Pathways"),
            p(class = "mb-0 small", "This analysis maps your significant proteins to known biological pathways (Reactome, GO) to discover enriched functional themes in your data.")
          )
        ),
        uiOutput("pathway_enrichment_content")
      )
    )
  )
}