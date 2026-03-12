plate_randomization_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("th"), " Plate Randomization & Layout Designer")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Plate Parameters",
            width = 320,
            
            h6(icon("grid"), " Format Settings", class = "mb-3 fw-bold text-primary"),
            selectInput("plate_size", "Format:", 
                        choices = c("96-well Plate" = 96, "48-well Plate" = 48), 
                        selected = 96),
            selectInput("plate_fill_color", "Color Code By:", choices = NULL),
            textInput("product", "Olink Product ID:", placeholder = "e.g., Explore 384"),
            
            hr(),
            
            h6(icon("flask"), " Control Management", class = "mb-3 fw-bold text-success"),
            numericInput("num_ctrl", "Number of Controls:", 
                         value = 8, min = 1, max = 20),
            checkboxInput("rand_ctrl", "Randomize Control Positions", value = FALSE),
            checkboxInput("include_label", "Annotate Wells with Labels", value = FALSE),
            
            hr(),
            
            actionButton("generate_plate_layout", " Visualize Layout", 
                         class = "btn-primary w-100 mb-2", icon = icon("eye")),
            downloadButton("download_plate_layout", " Export Map (PNG)", class = "btn-outline-success w-100")
          ),
          
          # Plot Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("plate_layout_plot", height = "650px")
          )
        )
      )
    )
  )
}