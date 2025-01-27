# heatmap plot ui

heatmap_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Heatmap Plot"),
          card_body("Heatmap",
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
                plotOutput("heatmap_plot"),
                downloadButton("download_heatmap", "Download Heatmap Plot")
          )
        )
      )
    )
  )
}