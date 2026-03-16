quality_control_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Quality Control Features"),
          card_body(
            tabsetPanel(
              tabPanel("QC Scatterplots",
                       selectInput("qc_x_var", "X-axis Variable:", choices = NULL),
                       selectInput("qc_y_var", "Y-axis Variable:", choices = NULL),
                       selectInput("qc_color_by", "Color by:", choices = c("None" = "", names(merged_data()))),
                       actionButton("generate_qc_plot", "Generate QC Plot"),
                       plotOutput("qc_plot")
              ),
              tabPanel("NPX Distribution",
                       selectInput("dist_panel", "Olink Panel:", choices = NULL),
                       checkboxInput("dist_log_scale", "Use Log Scale", value = FALSE),
                       actionButton("generate_dist_plot", "Generate Distribution Plot"),
                       plotOutput("dist_plot")
              )
            )
          )
        )
      )
    )
  )
}