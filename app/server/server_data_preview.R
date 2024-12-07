data_preview_server <- function(input, output, session, merged_data) {
  output$data_preview <- renderDT({
    req(merged_data())
    datatable(head(merged_data(), 100), options = list(scrollX = TRUE))
  })
}