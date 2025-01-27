pathway_heatmap_ui <- function() {
  tagList(
    fluidRow(
      column(12,
        h4("Pathway Heatmap"),
        p("Please ensure you have run the t-test and pathway enrichment analysis before generating the heatmap.")
      )
    ),
    fluidRow(
      column(4,
        selectInput("pathway_heatmap_method", "Enrichment Method:",
                    choices = c("GSEA", "ORA"),
                    selected = "GSEA")
      ),
      column(4,
        textInput("pathway_heatmap_keyword", "Keyword Filter (optional):", "")
      ),
      column(4,
        numericInput("pathway_heatmap_number_of_terms", "Number of Terms:",
                     value = 20, min = 1, max = 100)
      )
    ),
    fluidRow(
      column(12,
        actionButton("generate_pathway_heatmap", "Generate Pathway Heatmap"),
        textOutput("heatmap_status")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("pathway_heatmap_plot", height = "600px")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_pathway_heatmap", "Download Heatmap")
      )
    )
  )
}