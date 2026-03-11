wilcox_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("balance-scale"), " Non-parametric Analysis: Wilcoxon / Mann-Whitney"),
        downloadButton("download_wilcox", " Export CSV", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Test Configuration",
            width = 320,
            selectInput("mw_variable", "Grouping Variable:", choices = NULL),
            radioButtons("wilcox_var_type", "Variable Type", 
                         choices = c("Character", "Factor"),
                         selected = "Factor"),
            hr(),
            selectInput("alternative", "Alternative Hypothesis",
              choices = c(
                "Two Sided (Neutral)" = "two.sided",
                "Greater (Right-tail)" = "greater",
                "Less (Left-tail)" = "less"
              ),
              selected = "two.sided"
            ),
            br(),
            actionButton("run_mw_test", " Execute Wilcoxon Test", 
                         class = "btn-primary w-100 py-2", icon = icon("play-circle"))
          ),
          
          # Output area
          div(
            class = "p-0",
            div(
              class = "alert alert-warning border-0 mb-3 small py-2",
              icon("info-circle", class = "me-2"),
              "Recommended for non-normally distributed data or small sample sizes."
            ),
            DTOutput("wilcox_output")
          )
        )
      )
    )
  )
}