enhanced_visualization_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Enhanced Visualization"),
          card_body(
            tabsetPanel(
              tabPanel("UMAP Plot",
                       selectInput("umap_color_by", "Color by:", choices = NULL),
                       selectInput("umap_var_type", "Variable Type:", 
                                   choices = c("Factor", "Numeric", "Character"),
                                   selected = "Factor"),
                       checkboxInput("label_umap", "Label Points", value = FALSE),
                       actionButton("generate_umap", "Generate UMAP Plot"),
                       plotOutput("umap_plot"),
                       downloadButton("download_umap", "Download UMAP Plot")
              ),
              tabPanel("Heatmap",
                fluidRow(
                  column(4,
                    selectInput("heatmap_type", "Heatmap Type:",
                                choices = c("All Samples and Proteins", "Module-Trait Relationship")),
                    textInput("heatmap_title", "Heatmap Title:", 
                              value = "Heatmap of Samples and Proteins"),
                  ),
                  column(4,
                    textInput("heatmap_y_axis", "Y-axis Label:", value = "Samples"),
                    textInput("heatmap_x_axis", "X-axis Label:", value = "Proteins")
                  ),
                  column(4,
                    br(),
                    actionButton("generate_heatmap", "Generate Heatmap", 
                                 class = "btn-primary btn-block")
                  )
                ),
                br(),
                plotOutput("heatmap_plot")
              )            
              # Commented out Volcano Plot tab as in your original code
              # tabPanel("Volcano Plot",
              #          selectInput("volcano_comparison", "Comparison:", choices = NULL),
              #          actionButton("generate_volcano", "Generate Volcano Plot"),
              #          plotOutput("volcano_plot")
              # )
            )
          )
        )
      )
    )
  )
}