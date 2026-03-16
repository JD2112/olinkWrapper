descriptive_stats_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("table"), " Descriptive Statistics Summary"),
        actionButton("run_desc_stats", " Recompute Stats", 
                     class = "btn-success btn-sm", icon = icon("sync"))
      ),
      card_body(
        div(
          class = "alert alert-primary border-0 mb-3 small py-2 d-flex align-items-center",
          icon("info-circle", class = "me-2"),
          "Generates a comprehensive summary including Mean, Median, SD, and Range for all assays."
        ),
        div(
          class = "p-0",
          DTOutput("desc_stats_output")
        )
      )
    )
  )
}