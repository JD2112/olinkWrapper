ttest_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("balance-scale"), " Comparative Analysis: T-Test"),
        downloadButton("download_ttest", " Export CSV", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Test Settings",
            width = 300,
            selectInput("ttest_var", "Grouping Variable", choices = NULL),
            radioButtons("ttest_var_type", "Variable Type", 
                         choices = c("Character", "Factor"),
                         selected = "Character"),
            hr(),
            p(class = "small text-muted", 
              "Performs a two-sample t-test comparing NPX values between the two levels of the selected variable."),
            actionButton("run_ttest", " Execute T-Test", 
                         class = "btn-primary w-100 mt-2", 
                         icon = icon("play-circle"))
          ),
          
          # Output table
          div(
            class = "p-0 bg-white rounded-3",
            DTOutput("ttest_output")
          )
        )
      )
    )
  )
}