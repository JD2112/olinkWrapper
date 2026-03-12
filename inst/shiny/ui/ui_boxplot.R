boxplot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("chart-bar"), " Multi-Assay Boxplot Analysis")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Visualization Parameters",
            width = 320,
            
            h6(icon("layer-group"), " Data Grouping", class = "mb-3 fw-bold text-primary"),
            selectInput("boxplot_variable", "Categorical Group:", choices = NULL),
            selectizeInput("boxplot_olinkid_list", "Select Assays (Proteins):", 
                           choices = NULL, multiple = TRUE,
                           options = list(placeholder = 'Type to search...')),
            numericInput("boxplot_number_of_proteins", "Capacity (Max per view):", value = 6, min = 1),
            
            hr(),
            
            h6(icon("check-double"), " Significance Annotation", class = "mb-3 fw-bold text-success"),
            checkboxInput("boxplot_use_posthoc", "Overlay ANOVA Post-hoc P-values", value = FALSE),
            checkboxInput("boxplot_use_ttest", "Overlay T-test Significance", value = FALSE),
            
            hr(),
            
            actionButton("generate_boxplot", " Update Workspace", 
                         class = "btn-primary w-100 mb-2", icon = icon("sync-alt")),
            downloadButton("download_boxplot", " Export Graphics", class = "btn-outline-success w-100")
          ),
          
          # Content Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("boxplot", height = "700px")
          )
        )
      )
    )
  )
}