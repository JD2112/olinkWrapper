lme_posthoc_ui <- function() {
  tagList(
    card(
      class = "shadow-sm border-0 mb-4",
      card_header(
        class = "bg-primary text-white d-flex justify-content-between align-items-center",
        tagList(icon("user-md"), " Advanced LME Post-hoc Studio"),
        downloadButton("download_lme_posthoc", " Export CSV", class = "btn-success btn-sm")
      ),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            title = "Model Refinement",
            width = 340,
            
            h6(icon("layer-group"), " Variable Selection", class = "mb-3 fw-bold text-primary"),
            selectInput("lme_posthoc_variable", "Fixed Effects:", choices = NULL, multiple = TRUE),
            selectInput("lme_posthoc_random", "Random Effect Level:", choices = NULL),
            selectInput("lme_posthoc_effect", "Target Comparison Effect:", choices = NULL),
            
            hr(),
            
            h6(icon("vials"), " Assay Filters", class = "mb-3 fw-bold text-success"),
            checkboxInput("lme_use_significant_only", "Significant Assays Only", value = TRUE),
            textAreaInput("lme_posthoc_olinkid_list", "Custom Assay List:", 
                          placeholder = "e.g., BMP6, IL-6...", rows = 2),
            
            hr(),
            
            h6(icon("balance-scale"), " Correction Method", class = "mb-3 fw-bold text-muted"),
            selectInput("lme_posthoc_padjust_method", NULL,
                        choices = c("tukey", "sidak", "bonferroni", "none"),
                        selected = "tukey"),
            
            br(),
            actionButton("run_lme_posthoc", " Execute LME Post-hoc", 
                         class = "btn-primary w-100 py-2", icon = icon("play-circle"))
          ),
          
          # Output area
          div(
            class = "p-0",
            div(
              class = "alert alert-primary border-0 mb-3 small py-2 d-flex align-items-center",
              icon("info-circle", class = "me-2"),
              "Performs pair-wise comparisons within mixed effects models to resolve complex longitudinal differences."
            ),
            DTOutput("lme_posthoc_output")
          )
        )
      )
    )
  )
}