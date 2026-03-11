manual_exclusion_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("user-slash"), " Fine-grained Exclusion Studio"),
        span(class = "badge bg-warning text-dark", "Global Filtering")
      ),
      card_body(
        p("Tailor your dataset by manually removing specific samples or assays. These changes propagate through all current session analyses.", 
          class = "text-muted mb-4"),
        
        layout_column_wrap(
          width = 1/2,
          gap = "1.5rem",
          
          # Sample Exclusion Section
          div(
            class = "p-4 rounded-3",
            style = "background-color: #fffbeb; border: 1px solid #fde68a;",
            h5(icon("users"), " Exclude Samples", class = "mb-3", style = "color: #b45309;"),
            textAreaInput(
              "manual_exclude_samples",
              "Enter Sample IDs (comma-separated):",
              placeholder = "e.g., S101, S102, Control-A",
              rows = 4,
              width = "100%"
            ),
            div(
              class = "form-check form-switch mb-3",
              checkboxInput(
                "exclude_all_controls",
                "Flag & Exclude all STUDY CONTROLS",
                value = FALSE
              )
            ),
            actionButton(
              "preview_sample_exclusion",
              " Validate Selection",
              class = "btn-outline-warning w-100 mb-3",
              icon = icon("check-circle")
            ),
            div(
              class = "bg-white p-2 rounded border small",
              style = "min-height: 60px; max-height: 120px; overflow-y: auto;",
              verbatimTextOutput("sample_exclusion_preview")
            )
          ),
          
          # Protein Exclusion Section
          div(
            class = "p-4 rounded-3",
            style = "background-color: #f0f9ff; border: 1px solid #bae6fd;",
            h5(icon("dna"), " Exclude Proteins", class = "mb-3", style = "color: #0369a1;"),
            textAreaInput(
              "manual_exclude_proteins",
              "Enter Protein IDs (comma-separated):",
              placeholder = "e.g., BMP6, IL6, APOE",
              rows = 4,
              width = "100%"
            ),
            br(), br(),
            actionButton(
              "preview_protein_exclusion",
              " Validate Assay List",
              class = "btn-outline-info w-100 mb-3",
              icon = icon("check-circle")
            ),
            div(
              class = "bg-white p-2 rounded border small",
              style = "min-height: 60px; max-height: 120px; overflow-y: auto;",
              verbatimTextOutput("protein_exclusion_preview")
            )
          )
        ),
        
        hr(class = "my-4"),
        
        # Action Bar
        div(
          class = "text-center py-3",
          actionButton(
            "apply_manual_exclusions",
            " Finalize & Apply Permanent Exclusions",
            class = "btn-danger btn-lg px-5 shadow",
            icon = icon("shield-alt")
          ),
          div(
            class = "mt-4 p-3 bg-white border rounded shadow-sm text-start mx-auto",
            style = "max-width: 800px;",
            h6(icon("info-circle"), " Exclusion Audit Summary", class = "mb-2 fw-bold text-muted"),
            verbatimTextOutput("exclusion_summary")
          )
        )
      )
    )
  )
}
