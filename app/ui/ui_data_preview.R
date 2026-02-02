data_preview_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Data Management"),
          card_body(
            layout_column_wrap(
              width = 1/2,
              div(
                downloadButton("download_full_data", "Download Full Dataset", class = "btn-secondary w-100"),
                br(), br(),
                downloadButton("download_var_key_data", "Download Var-Key Merged Data", class = "btn-secondary w-100")
              ),
              div(
                actionButton("filter_qc_warnings", "Exclude samples with QC Warning", class = "btn-danger w-100"),
                br(), br(),
                verbatimTextOutput("qc_filter_status")
              )
            )
          )
        )
      )
    ),
    br(),
    DTOutput("data_preview")
  )
}