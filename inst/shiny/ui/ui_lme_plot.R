lme_plot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("chart-line"), " Longitudinal & Mixed Effects Visualization")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Aesthetic Mapping",
            width = 320,
            div(
              class = "alert alert-info py-2 small mb-3",
              icon("info-circle"), " Choose a random effect (e.g. Subject ID) and x-axis (e.g. Timepoint). NPX is always the Y-axis."
            ),
            h6(icon("dna"), " Assay Data", class = "mb-3 fw-bold text-primary"),
            selectizeInput("lme_plot_olinkid_list", "Target Assays:",
              choices = NULL, multiple = TRUE,
              options = list(placeholder = "Search proteins...")
            ),
            hr(),
            h6(icon("map-marker-alt"), " Axis & Faceting", class = "mb-3 fw-bold text-success"),
            selectInput("lme_plot_x_axis_variable", "X-axis (Time/Group):", choices = NULL),
            selectInput("lme_plot_col_variable", "Color Legend:", choices = NULL),
            selectizeInput("lme_plot_variable", "Fixed Effect Variables:",
              choices = NULL, multiple = TRUE,
              options = list(placeholder = "Select one or more...")
            ),
            selectInput("lme_plot_random", "Random Effect Level (ID):", choices = NULL),
            hr(),
            actionButton("generate_lme_plot", " Refresh Visualization",
              class = "btn-primary w-100 mb-2", icon = icon("sync")
            ),
            downloadButton("download_lme_plot", " Export High-Res PNG", class = "btn-outline-success w-100")
          ),

          # Content Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("lme_plot_output", height = "750px")
          )
        )
      )
    )
  )
}
