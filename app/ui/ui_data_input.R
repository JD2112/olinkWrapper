data_input_ui <- function() {
  sidebar(
    title = "Data Input",
    fileInput("npx_file", "Upload NPX Data (CSV)", accept = c(".csv")),
    fileInput("key_file", "Upload Key File (CSV, Optional)", accept = c(".csv")),
    fileInput("var_file", "Upload Variables File (CSV)", accept = c(".csv")),
    actionButton("merge_data", "Merge Data", class = "btn-primary"),
    HTML("<hr> <a href='ShinyOlink.txt' target='_blank'> <i class='fa fa-download'> </i> HOW TO USE</a>")
  )
}