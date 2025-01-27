data_preview_ui <- function() {
  tagList(
    downloadButton("download_full_data", "Download Full Dataset"),
    br(),
    br(),
    DTOutput("data_preview")
  )
}