umap_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("project-diagram"), " UMAP: Dimensionality Reduction")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Plot Controls",
            width = 300,
            selectInput("umap_color_by", "Color Samples By:", choices = NULL),
            selectInput("umap_var_type", "Variable Type:", 
                        choices = c("Factor", "Numeric", "Character"),
                        selected = "Factor"),
            checkboxInput("label_samples", "Show Sample IDs", value = FALSE),
            hr(),
            actionButton("generate_umap", " Update View", class = "btn-primary w-100", icon = icon("sync")),
            br(),
            downloadButton("download_umap", " Save Export", class = "btn-outline-success w-100 mt-2")
          ),
          # Main Plot Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("umap_plot", height = "650px")
          )
        )
      )
    )
  )
}