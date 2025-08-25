plot_customization_server <- function(input, output, session) {
  
  observeEvent(input$apply_plot_settings, {
    # Set the plot theme
    theme <- switch(input$plot_theme,
                    "Minimal" = theme_minimal(),
                    "Classic" = theme_classic(),
                    "Dark" = theme_dark(),
                    theme_grey())  # Default
    set_plot_theme(theme)
    
    # Set the color palette
    olink_color_discrete(input$color_palette)
    
    showNotification("Plot settings applied.", type = "message")
  })
}