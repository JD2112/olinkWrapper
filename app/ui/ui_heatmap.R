heatmap_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("th"), " Hierarchy & Clustering Heatmap")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Visualization Controls",
            width = 300,
            selectInput("heatmap_type", "Heatmap Logic:",
                        choices = c("All Samples and Proteins" = "All Samples and Proteins", 
                                  "Module-Trait Relationship" = "Module-Trait Relationship")),
            
            hr(),
            div(
              class = "bg-light p-3 rounded-3 mb-3",
              textInput("heatmap_title", "Plot Title:", 
                        value = "Heatmap of Samples and Proteins"),
              textInput("heatmap_y_axis", "Y-axis Label:", value = "Samples"),
              textInput("heatmap_x_axis", "X-axis Label:", value = "Proteins")
            ),
            
            actionButton("generate_heatmap", " Render Heatmap", 
                         class = "btn-primary w-100 py-2", icon = icon("sync")),
            br(),
            downloadButton("download_heatmap", " Download heatmap", class = "btn-outline-success w-100 mt-2")
          ),
          # Main Plot Area
          div(
            class = "p-2 bg-white rounded-3 border",
            plotOutput("heatmap_plot", height = "750px")
          )
        )
      )
    )
  )
}