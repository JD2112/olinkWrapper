plate_randomization_ui <- function() {
  tagList(
    fluidRow(
      column(4,
        selectInput("plate_fill_color", "Fill Color Variable:", choices = NULL)
      ),
      column(4,
        selectInput("plate_size", "Plate Size:", 
                    choices = c("96" = 96, "48" = 48), 
                    selected = 96)
      ),
      column(4,
        numericInput("num_ctrl", "Number of Controls:", 
                     value = 8, min = 1, max = 20)
      )
    ),
    fluidRow(
      column(4,
        checkboxInput("rand_ctrl", "Randomize Controls", value = FALSE)
      ),
      column(4,
        textInput("product", "Olink Product:", placeholder = "Optional")
      ),
      column(4,
        checkboxInput("include_label", "Include Labels", value = FALSE)
      )
    ),
    fluidRow(
      column(12,
        actionButton("generate_plate_layout", "Generate Plate Layout")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("plate_layout_plot", height = "600px")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_plate_layout", "Download Plate Layout")
      )
    )
  )
}