lod_integration_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white",
        tagList(icon("microscope"), " Limit of Detection (LOD) Management")
      ),
      card_body(
        layout_column_wrap(
          width = 1/2,
          gap = "1.5rem",
          div(
            class = "p-4 rounded-3 h-100",
            style = "background-color: #f8fafc; border: 1px solid #e2e8f0;",
            h5(icon("link"), " 1. Integration", class = "mb-3", style = "color: var(--primary);"),
            p("Synchronize clinical data with Olink LOD parameters to label measurements correctly.", class = "text-muted small mb-4"),
            actionButton("integrate_lod", " Integrate LOD Data", class = "btn-secondary w-100 py-2", icon = icon("database")),
            div(
              class = "mt-3 p-2 bg-white rounded border small",
              style = "min-height: 50px;",
              verbatimTextOutput("lod_integration_results")
            )
          ),
          div(
            class = "p-4 rounded-3 h-100",
            style = "background-color: #fff1f2; border: 1px solid #fecdd3;",
            h5(icon("filter"), " 2. Low Quality Filtering", class = "mb-3 text-danger"),
            p("Proteins with >50% of counts below LOD are flagged for exclusion to improve statistical power.", class = "text-muted small mb-4"),
            actionButton("filter_lod_proteins", " Remove Flagged Proteins", class = "btn-danger w-100 py-2", icon = icon("trash-alt"))
          )
        ),
        
        hr(class = "my-4"),
        
        div(
          class = "p-3",
          h6(icon("eye"), " Flagged Assay Summary ( >50% Below LOD )", class = "mb-3 fw-bold"),
          div(
            class = "overflow-hidden",
            DT::dataTableOutput("below_lod_table")
          )
        )
      )
    )
  )
}