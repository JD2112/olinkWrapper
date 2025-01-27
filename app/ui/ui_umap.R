# umap plot ui

umap_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Enhanced Visualization"),
          card_body("UMAP Plot",
            fluidRow(
                column(4,
                    selectInput("umap_color_by", "Color by:", choices = NULL)
                ),
                column(4,
                    selectInput("umap_var_type", "Variable Type:", 
                                choices = c("Factor", "Numeric", "Character"),
                                selected = "Factor")
                ),
                column(4,
                    checkboxInput("label_samples", "Label Points", value = FALSE),
                    #checkboxInput("label_outliers", "Label Outliers", value = FALSE),
                    actionButton("generate_umap", "Generate UMAP Plot")
                )
            ),
            br(),                    
            plotOutput("umap_plot"),
            downloadButton("download_umap", "Download UMAP Plot")
            )
        )
    )
    )
)}