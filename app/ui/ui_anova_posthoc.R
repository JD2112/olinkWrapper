anova_posthoc_ui <- function() {
  tagList(
    selectInput("posthoc_effect", "Effect for Post-hoc:", choices = c("", "")),
    checkboxInput("use_significant_only", "Use only significant assays", value = TRUE),
    textInput("posthoc_olinkid_list", "Custom Olink ID List (comma-separated, optional):", ""),
    checkboxInput("posthoc_mean_return", "Return Means", value = FALSE),
    selectInput("posthoc_padjust_method", "Post-hoc Adjustment Method:",
                choices = c("tukey", "bonferroni", "holm", "hochberg", "none"),
                selected = "tukey"),
    checkboxInput("posthoc_verbose", "Verbose", value = TRUE),
    actionButton("run_anova_posthoc", "Run ANOVA Post-hoc Analysis"),
    # verbatimTextOutput("posthoc_formula_used"),
    DTOutput("anova_posthoc_output"),
    downloadButton("download_anova_posthoc", "Download Post-hoc Results")
  )
}