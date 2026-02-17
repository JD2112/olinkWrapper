# Manual Exclusion UI

manual_exclusion_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("Manual Sample and Protein Exclusion"),
          card_body(
            p("Manually exclude specific samples or proteins from your analysis. Exclusions will affect all downstream analyses."),
            
            layout_column_wrap(
              width = 1/2,
              
              # Sample Exclusion Panel
              card(
                card_header("Exclude Samples", class = "bg-warning"),
                card_body(
                  textAreaInput(
                    "manual_exclude_samples",
                    "Enter Sample IDs to exclude (comma-separated):",
                    placeholder = "e.g., Sample001, Sample002, Sample003",
                    rows = 4,
                    width = "100%"
                  ),
                  checkboxInput(
                    "exclude_all_controls",
                    "Exclude all control samples (SampleType == 'CONTROL')",
                    value = FALSE
                  ),
                  actionButton(
                    "preview_sample_exclusion",
                    "Preview Sample Exclusion",
                    class = "btn-info w-100"
                  ),
                  br(), br(),
                  verbatimTextOutput("sample_exclusion_preview")
                )
              ),
              
              # Protein Exclusion Panel
              card(
                card_header("Exclude Proteins", class = "bg-warning"),
                card_body(
                  textAreaInput(
                    "manual_exclude_proteins",
                    "Enter Olink IDs (Assay names) to exclude (comma-separated):",
                    placeholder = "e.g., BMP6, EPHX2, PGLYRP1",
                    rows = 4,
                    width = "100%"
                  ),
                  actionButton(
                    "preview_protein_exclusion",
                    "Preview Protein Exclusion",
                    class = "btn-info w-100"
                  ),
                  br(), br(),
                  verbatimTextOutput("protein_exclusion_preview")
                )
              )
            ),
            
            hr(),
            
            # Apply Exclusions
            fluidRow(
              column(
                width = 12,
                align = "center",
                actionButton(
                  "apply_manual_exclusions",
                  "Apply All Exclusions",
                  class = "btn-danger btn-lg",
                  icon = icon("filter")
                ),
                br(), br(),
                verbatimTextOutput("exclusion_summary")
              )
            )
          )
        )
      )
    )
  )
}
