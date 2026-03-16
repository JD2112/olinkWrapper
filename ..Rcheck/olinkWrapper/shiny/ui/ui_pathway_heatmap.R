pathway_heatmap_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("project-diagram"), " Biological Pathway Visualization")
      ),
      card_body(
        div(
          class = "alert alert-info border-0 mb-4 d-flex align-items-center",
          icon("info-circle", class = "me-3 fs-4"),
          div(
            p(class = "mb-0 fw-bold", "Prerequisite Check"),
            p(class = "mb-0 small", "Ensure you have completed both T-Test and Enrichment Analysis steps before rendering.")
          )
        ),
        
        layout_sidebar(
          sidebar = sidebar(
            title = "Analysis Filters",
            width = 320,
            selectInput("pathway_heatmap_method", "Enrichment Method:",
                        choices = c("GSEA" = "GSEA", "ORA" = "ORA"),
                        selected = "GSEA"),
            hr(),
            textInput("pathway_heatmap_keyword", "Keyword Keyword Filter:", 
                      placeholder = "e.g., Immune, Signaling"),
            numericInput("pathway_heatmap_number_of_terms", "Display Limit (Max Terms):",
                         value = 20, min = 1, max = 100),
            
            hr(),
            actionButton("generate_pathway_heatmap", " Generate Plot", 
                         class = "btn-primary w-100 mb-2", icon = icon("sync-alt")),
            downloadButton("download_pathway_heatmap", " Export Map", 
                           class = "btn-outline-success w-100"),
            br(), br(),
            div(class = "small text-muted text-center", textOutput("heatmap_status"))
          ),
          
          # Plot Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("pathway_heatmap_plot", height = "700px")
          )
        )
      )
    )
  )
}