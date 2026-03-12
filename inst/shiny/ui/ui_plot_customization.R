plot_customization_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("palette"), " Global Aesthetic Preferences")
      ),
      card_body(
        div(
          class = "row justify-content-center",
          div(
            class = "col-md-8",
            div(
              class = "p-4 bg-light rounded-3 border",
              h6(icon("paint-roller"), " Theme & Brand Colors", class = "mb-4 fw-bold"),
              
              layout_column_wrap(
                width = 1/2,
                selectInput("plot_theme", "Visual Theme:", 
                            choices = c("Default", "Minimal", "Classic", "Dark")),
                colourpicker::colourInput("color_palette", "Primary Brand Color:", value = "#1f77b4")
              ),
              
              br(),
              div(
                class = "text-center",
                actionButton("apply_plot_settings", " Apply Aesthetic Changes", 
                             class = "btn-primary px-5 py-2", icon = icon("check-circle"))
              )
            )
          )
        ),
        
        br(),
        div(
          class = "alert alert-secondary border-0 mb-0 small",
          style = "background-color: #f8fafc;",
          tagList(icon("info-circle"), " These settings will be applied to all newly generated plots in the current session.")
        )
      )
    )
  )
}