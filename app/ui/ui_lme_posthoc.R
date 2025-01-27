lme_posthoc_ui <- function() {
  tagList(
    fluidRow(
      column(
        width = 12,
        card(
          card_header("LME Post-hoc Analysis"),
          card_body(
            fluidRow(
              column(4,
                selectInput("lme_posthoc_variable", "Variables:", choices = NULL, multiple = TRUE)
              ),
              column(4,
                selectInput("lme_posthoc_random", "Random Effect:", choices = NULL)
              ),
              column(4,
                selectInput("lme_posthoc_effect", "Post-hoc Effect:", choices = NULL)
              )
            ),
            fluidRow(
              column(4,
                checkboxInput("lme_use_significant_only", "Use Only Significant Assays", value = TRUE)
              ),
              column(4,
                textInput("lme_posthoc_olinkid_list", "Custom OlinkID List (comma-separated):")
              ),
              column(4,
                selectInput("lme_posthoc_padjust_method", "P-value Adjustment Method:",
                            choices = c("tukey", "sidak", "bonferroni", "none"),
                            selected = "tukey")
              )
            ),
            fluidRow(
              column(12,
                actionButton("run_lme_posthoc", "Run Post-hoc Analysis")
              )
            ),
            DTOutput("lme_posthoc_output"),
            downloadButton("download_lme_posthoc", "Download Post-hoc Results")
          )
        )
      )
    )
  )
}