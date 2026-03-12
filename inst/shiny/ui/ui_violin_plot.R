violin_plot_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("music"), " Enhanced Violin & Density Analysis")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Plot Customization",
            width = 300,
            selectInput("violin_protein", "Target Assay / Protein", choices = NULL),
            selectInput("violin_group", "Primary Categorical Group", choices = NULL),
            radioButtons("violin_var_type", "Data Class", 
                         choices = c("Character", "Factor"),
                         selected = "Factor"),
            hr(),
            p(class = "small text-muted", 
              "Violin plots provide a compact view of data distribution density across groups."),
            actionButton("run_violin", " Render Performance", 
                         class = "btn-primary w-100 py-2", icon = icon("paint-brush")),
            br(),
            downloadButton("download_violin", " Save Analysis", class = "btn-outline-success w-100 mt-2")
          ),
          
          # Content Area
          div(
            class = "p-3 bg-white rounded-3 border",
            plotOutput("violin_plot", height = "650px")
          )
        )
      )
    )
  )
}