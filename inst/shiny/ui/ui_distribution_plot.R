distribution_plot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("wave-square"), " Global NPX Distribution Profile")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Aesthetic Filters",
            width = 300,
            selectInput("dist_color_variable", "Color Density By:", choices = NULL),
            radioButtons("dist_var_type", "Data Type:", 
                         choices = c("Character", "Factor"), 
                         selected = "Factor"),
            hr(),
            p(class = "small text-muted", 
              "Visualizes the overall spread and symmetry of NPX values across all samples."),
            actionButton("generate_dist_plot", " Update Distribution", 
                         class = "btn-primary w-100 py-2", icon = icon("sync")),
            br(),
            downloadButton("download_dist_plot", " Export Density Map", class = "btn-outline-success w-100 mt-2")
          ),
          
          # Content Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("distribution_plot", height = "650px")
          )
        )
      )
    )
  )
}