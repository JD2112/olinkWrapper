start_page_ui <- function() {
  fluidPage(
    div(class = "start-page-content",
      h1("olinkWrappeR: Shiny Interface for Olink Data Analysis"),
      # p("Choose your analysis type:"),
      div(class = "radio-buttons-center",
        radioButtons("analysis_type", "",
                     choices = c("olinkWrappeR" = "single"#,
                                 #"Multi-Panel" = "multi"
                                 ),
                     selected = "single")
      ),
      actionButton("start_analysis", "Start Analysis", class = "btn-primary"),
      br(),
      br(),
      textOutput("analysis_description")
    )
  )
}