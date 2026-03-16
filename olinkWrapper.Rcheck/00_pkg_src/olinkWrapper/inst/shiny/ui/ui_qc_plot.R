qc_plot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("vials"), " Data Quality Control (QC) Panel")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "QC Plot Parameters",
            width = 350,
            
            h6(icon("palette"), " Visual Grouping", class = "mb-2 mt-2 fw-bold text-primary"),
            selectInput("qc_color_g", "Color Grouping:", choices = NULL, selected = "QC_Warning"),
            selectInput("qc_var_type", "Variable Type:", choices = c("Factor", "Character"), selected = "Character"),
            
            hr(),
            
            h6(icon("exclamation-triangle"), " Outlier Configuration", class = "mb-2 fw-bold text-danger"),
            checkboxInput("qc_label_outliers", "Label Outliers", value = TRUE),
            checkboxInput("qc_outlierLines", "Show Outlier Lines", value = TRUE),
            
            layout_column_wrap(
              width = 1/2,
              numericInput("qc_IQR_outlierDef", "IQR Def:", value = 3, min = 1, max = 10, step = 0.5),
              numericInput("qc_median_outlierDef", "Med Def:", value = 3, min = 1, max = 10, step = 0.5)
            ),
            
            hr(),
            
            h6(icon("th-large"), " Facet Layout", class = "mb-2 fw-bold text-muted"),
            layout_column_wrap(
              width = 1/2,
              numericInput("qc_facetNrow", "Rows:", value = 1, min = 1),
              numericInput("qc_facetNcol", "Columns:", value = 1, min = 1)
            ),
            
            hr(),
            
            actionButton("generate_qc_plot", " Refresh QC Analysis", 
                         class = "btn-primary w-100 mb-2", icon = icon("sync")),
            downloadButton("download_qc_plot", " Export PNG", class = "btn-outline-success w-100")
          ),
          
          # Main Result Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("qc_plot", height = "700px")
          )
        )
      )
    )
  )
}