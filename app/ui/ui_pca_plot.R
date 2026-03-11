pca_plot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("project-diagram"), " Principal Component Analysis (PCA)")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "PCA Configuration",
            width = 300,
            selectInput("pca_var", "Color Points By:", choices = NULL),
            radioButtons("pca_var_type", "Variable Type:", 
                         choices = c("Character", "Factor", "Numeric"),
                         selected = "Factor"),
            checkboxInput("label_pca", "Show Sample Labels", value = FALSE),
            hr(),
            p(class = "small text-muted", 
              "Reduces data dimensionality to capture the most variance in fewer dimensions."),
            actionButton("run_pca", " Update PCA View", 
                         class = "btn-primary w-100 py-2", icon = icon("sync")),
            br(),
            downloadButton("download_pca", " Export Plot", class = "btn-outline-success w-100 mt-2")
          ),
          
          # Plot Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("pca_plot", height = "650px")
          )
        )
      )
    )
  )
}