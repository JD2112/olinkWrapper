volcano_plot_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 4,
        card(
          class = "shadow-sm border-0",
          card_header(
            class = "bg-primary text-white",
            tagList(icon("sliders-h"), " Plot Settings")
          ),
          card_body(
            div(
              class = "mb-4",
              h6(icon("vial"), " Analysis Selection", class = "mb-3 fw-bold text-primary"),
              radioButtons("volcano_plot_type", NULL, 
                           choices = c("T-test" = "ttest", 
                                     "ANOVA" = "anova",
                                     "Wilcoxon Test" = "wilcox")),
            ),
            
            hr(),
            
            div(
              class = "mb-4",
              h6(icon("percentage"), " Significance Parameters", class = "mb-3 fw-bold text-primary"),
              radioButtons("volcano_p_val_type", "P-value Method",
                           choices = c("Adjusted P-value (FDR)" = "Adjusted_pval", 
                                     "P-value (unadjusted)" = "p.value")),
              
              numericInput("volcano_p_threshold", "Threshold (alpha)", 
                           value = 0.05, min = 0, max = 1, step = 0.01),
            ),
            
            hr(),
            
            div(
              class = "mb-4",
              h6(icon("tags"), " Annotation", class = "mb-3 fw-bold text-primary"),
              checkboxInput("volcano_label_sig", "Label significant proteins", value = FALSE),
            ),
            
            actionButton("run_volcano", " Update Volcano Plot", class = "btn-primary w-100 py-2 fw-bold", icon = icon("sync-alt"))
          )
        )
      ),
      column(
        width = 8,
        card(
          class = "shadow-sm border-0",
          card_header(
            class = "bg-white",
            div(
              class = "d-flex justify-content-between align-items-center",
              h5(icon("fire"), " Volcano Plot Visualization", class = "mb-0", style = "color: var(--primary);"),
              downloadButton("download_volcano", " Export PNG", class = "btn-outline-success btn-sm")
            )
          ),
          card_body(
            class = "p-0",
            div(
              style = "background: #ffffff; padding: 20px; border-radius: 0 0 12px 12px;",
              plotOutput("volcano_plot", height = "650px")
            )
          )
        )
      )
    )
  )
}