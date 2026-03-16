data_input_ui <- function() {
  sidebar(
    title = "Analysis Configuration",
    width = 350,

    # Section: Data Upload
    h5(icon("cloud-upload"), " Data Upload", class = "mb-3 mt-2", style = "color: var(--accent);"),
    div(
      class = "compact-uploads",
      fileInput("npx_file", "1. NPX Data (CSV)", accept = c(".csv")),
      # fileInput("npx_file_2", "2. NPX Data 2 (CSV, Optional)", accept = c(".csv")),
      tags$details(
        tags$summary(
          tags$b("2. NPX Data 2 (CSV, Optional)")
        ),
        div(
          style = "margin-top: 10px;",
          fileInput("npx_file_2", NULL, accept = c(".csv"))
        )
      ),
      fileInput("var_file", "3. Variables File (CSV)", accept = c(".csv")),
      fileInput("key_file", "4. Key File (CSV, Optional)", accept = c(".csv"))
    ),

    # Section: Data Processing
    h5(icon("cogs"), " Processing", class = "mb-3", style = "color: var(--accent);"),
    selectInput("merge_key", "Match NPX & Var by:",
      choices = c("SampleID", "SUBJID"),
      selected = "SUBJID"
    ),
    div(
      class = "d-grid gap-2",
      actionButton("merge_data", "Merge NPX & Var", class = "btn-primary"),
      actionButton("merge_var_key", "Add Key to Var", class = "btn-secondary")
    ),
    # Section: Resources & Citation
    # h5(icon("info-circle"), " Resources", class = "mb-3", style = "color: var(--accent);"),
    # div(
    #   class = "list-group list-group-flush bg-transparent",
    #   tags$a(
    #     href = "ShinyOlink.txt",
    #     target = "_blank",
    #     class = "list-group-item list-group-item-action bg-transparent text-white border-0 py-1",
    #     tagList(icon("file-download"), " Installation & Usage Guide")
    #   )
    # ),
    br(),
    br(),
    div(
      class = "p-3 rounded bg-dark",
      style = "background: rgba(255,255,255,0.05) !important;",
      p(strong("Cite olinkWrappeR:"), style = "font-size: 1.2rem; margin-bottom: 0.5rem;"),
      a(
        href = "https://doi.org/10.5281/zenodo.15098644",
        target = "_blank",
        img(src = "https://zenodo.org/badge/DOI/10.5281/zenodo.15098644.svg", alt = "DOI", style = "max-width: 100%;")
      )
    ),
    br(),
    div(
      style = "font-size: 1.2rem; opacity: 1.0; padding: 0 5px;",
      p(strong("Disclaimer:"), "olinkWrappeR is based on the"),
      a(href = "https://cran.r-project.org/web/packages/OlinkAnalyze/index.html", target = "_blank", " OlinkAnalyze R package.")
    )
  )
}
