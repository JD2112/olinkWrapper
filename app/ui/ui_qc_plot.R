qc_plot_ui <- function() {
  tagList(
    fluidRow(
      column(4,
        selectInput("qc_color_g", "Color Grouping:", choices = NULL, selected = "QC_Warning")
      ),
      column(4,
        selectInput("qc_var_type", "Variable Type:", choices = c("Factor", "Character"), selected = "Character")
      ),
      column(4,
        checkboxInput("qc_label_outliers", "Label Outliers", value = TRUE)
      )
    ),
    fluidRow(
      column(4,
        numericInput("qc_IQR_outlierDef", "IQR Outlier Definition:", value = 3, min = 1, max = 10, step = 0.5)
      ),
      column(4,
        numericInput("qc_median_outlierDef", "Median Outlier Definition:", value = 3, min = 1, max = 10, step = 0.5)
      ),
      column(4,
        checkboxInput("qc_outlierLines", "Show Outlier Lines", value = TRUE)
      )
    ),
    fluidRow(
      column(4,
        numericInput("qc_facetNrow", "Number of Rows:", value = 1, min = 1)
      ),
      column(4,
        numericInput("qc_facetNcol", "Number of Columns:", value = 1, min = 1)
      ),
      column(4,
        actionButton("generate_qc_plot", "Generate QC Plot")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("qc_plot", height = "600px")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_qc_plot", "Download QC Plot")
      )
    )
  )
}