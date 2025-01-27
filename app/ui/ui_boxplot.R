# ui/ui_boxplot.R

boxplot_ui <- function() {
  tagList(
    fluidRow(
      column(4,
        selectInput("boxplot_variable", "Grouping Variable:", choices = NULL)
      ),
      column(4,
        selectizeInput("boxplot_olinkid_list", "Select OlinkIDs:", choices = NULL, multiple = TRUE)
      ),
      column(4,
        numericInput("boxplot_number_of_proteins", "Number of Proteins per Plot:", value = 6, min = 1)
      )
    ),
    fluidRow(
      column(4,
        checkboxInput("boxplot_use_posthoc", "Use ANOVA Post-hoc Results", value = FALSE)
      ),
      column(4,
        checkboxInput("boxplot_use_ttest", "Use T-test Results", value = FALSE)
      ),
      column(4,
        actionButton("generate_boxplot", "Generate Boxplot")
      )
    ),
    fluidRow(
      column(12,
        plotOutput("boxplot")
      )
    ),
    fluidRow(
      column(12,
        downloadButton("download_boxplot", "Download Plot")
      )
    )
  )
}