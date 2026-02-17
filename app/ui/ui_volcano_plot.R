volcano_plot_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 4,
        card(
          card_header("Volcano Plot Settings"),
          card_body(
            radioButtons("volcano_plot_type", "Select Analysis Type", 
                         choices = c("T-test" = "ttest", 
                                   "ANOVA" = "anova",
                                   "Mann-Whitney U Test" = "wilcox")),
            radioButtons("volcano_p_val_type", "P-value for significance line",
                         choices = c("Adjusted P-value (FDR)" = "Adjusted_pval", 
                                   "P-value (unadjusted)" = "p.value")),

            numericInput("volcano_p_threshold", "Significance Threshold (p < x):", 
                         value = 0.05, min = 0, max = 1, step = 0.01),
            checkboxInput("volcano_label_sig", "Annotate significant proteins", value = FALSE),
            actionButton("run_volcano", "Generate Volcano Plot", class = "btn-primary w-100")
          )
        )
      ),
      column(
        width = 8,
        card(
          card_header("Volcano Plot"),
          card_body(
            plotOutput("volcano_plot", height = "600px"),
            downloadButton("download_volcano", "Download Plot", class = "btn-success mt-2")
          )
        )
      )
    )
  )
}