anova_posthoc_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("vial"), " Post-hoc Analysis (Tukey/Adjusted Comparisons)"),
        downloadButton("download_anova_posthoc", " Export Excel", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Post-hoc Parameters",
            width = 340,

            # ── Effect Variable ────────────────────────────
            h6(icon("bullseye"), " Effect Variable", class = "mb-2 fw-bold text-primary"),
            selectInput("posthoc_effect", "Effect (term from ANOVA):",
              choices = c("(Run ANOVA first)" = ""),
              selected = ""
            ),
            helpText("Select which ANOVA term to decompose into pairwise comparisons.", class = "small text-muted"),

            # ── Outcome ────────────────────────────────────
            h6(icon("chart-line"), " Outcome Variable", class = "mb-2 fw-bold text-info"),
            selectInput("posthoc_outcome", "Outcome:",
              choices = c("NPX"),
              selected = "NPX"
            ),
            helpText("The dependent variable. Default is NPX.", class = "small text-muted"),

            # ── Assay Filtering ────────────────────────────
            h6(icon("filter"), " Assay Selection", class = "mb-2 fw-bold text-success"),
            checkboxInput("use_significant_only", "Significant Assays Only", value = TRUE),
            helpText("If checked, only assays that were significant in ANOVA for the selected effect are tested.", class = "small text-muted"),
            textAreaInput("posthoc_olinkid_list", "Custom OlinkID List (optional):",
              placeholder = "OID00001, OID00002, ...",
              rows = 2
            ),
            helpText("Comma-separated. Overrides 'Significant Only' if provided.", class = "small text-muted"),

            # ── P-value Adjustment ─────────────────────────
            h6(icon("sliders-h"), " P-value Adjustment", class = "mb-2 fw-bold text-warning"),
            selectInput("posthoc_padjust_method", "Adjustment Method:",
              choices = c(
                "Tukey" = "tukey",
                "Sidak" = "sidak",
                "Bonferroni" = "bonferroni",
                "None" = "none"
              ),
              selected = "tukey"
            ),

            # ── Options ────────────────────────────────────
            h6(icon("cog"), " Options", class = "mb-2 fw-bold text-secondary"),
            checkboxInput("posthoc_mean_return", "Calculate Group Means", value = FALSE),
            helpText("If checked, group means per assay are appended to the results.", class = "small text-muted"),
            checkboxInput("posthoc_verbose", "Verbose Output", value = TRUE),
            helpText("Print progress messages to the R console.", class = "small text-muted"),
            br(),
            actionButton("run_anova_posthoc", " Compute Post-hoc",
              class = "btn-primary w-100 py-2", icon = icon("calculator")
            )
          ),

          # ── Output area ────────────────────────────────
          div(
            class = "p-0",
            div(
              class = "alert alert-info border-0 mb-3 small py-2",
              icon("info-circle", class = "me-2"),
              "Post-hoc tests identify which specific groups differ after a significant ANOVA. ",
              "The ", tags$code("variable"), " and ", tags$code("covariates"),
              " are automatically inherited from your ANOVA run. You only need to select the ",
              tags$strong("Effect"), " term to decompose."
            ),
            verbatimTextOutput("posthoc_summary"),
            DTOutput("anova_posthoc_output")
          )
        )
      )
    )
  )
}
