library(shiny)
library(bslib)

# Source UI components
source("ui/ui_data_input.R")
source("ui/ui_data_preview.R")
source("ui/ui_descriptive_stats.R")
source("ui/ui_normality_test.R")
source("ui/ui_pca_plot.R")
source("ui/ui_ttest.R")
source("ui/ui_violin_plot.R")
source("ui/ui_volcano_plot.R")
source("ui/ui_anova.R")
source("ui/ui_outlier_detection.R")
source("ui/ui_enhanced_visualization.R")
source("ui/ui_normalization.R")
source("ui/ui_pathway_enrichment.R")
source("ui/ui_lod_integration.R")
source("ui/ui_heatmap.R")
source("ui/ui_umap.R")
source("ui/ui_bridge_sample.R")
source("ui/ui_wilcox.R")
source("ui/ui_anova_posthoc.R")
source("ui/ui_lme.R")
source("ui/ui_lme_posthoc.R")
# source("ui/ui_additional_stats.R")
source("ui/ui_lme_stats.R")
source("ui/ui_boxplot.R")
source("ui/ui_distribution_plot.R")
source("ui/ui_lme_plot.R")
source("ui/ui_pathway_heatmap.R")
source("ui/ui_qc_plot.R")
source("ui/ui_manual_exclusion.R")
# source("ui/ui_plate_randomization.R")
source("ui/ui_linear_regression.R")
source("ui/ui_analysis_report.R")


single_ui <- function() {
  page_sidebar(
    theme = bs_theme(
      version = 5,
      primary = "#004e92",
      secondary = "#006FB7",
      base_font = font_google("Inter"),
      heading_font = font_google("Inter")
    ),
    div(
      class = "header-hero py-4 text-center",
      h1("olinkWrappeR", style = "margin-bottom: 0.5rem;"),
      p("A Modern Shiny Interface for Olink Data Analysis",
        class = "text-muted lead",
        style = "font-size: 1.1rem; font-weight: 400;"
      )
    ),
    sidebar = data_input_ui(),
    navset_tab(
      id = "main_nav",
      nav_panel("A. Data Preview", data_preview_ui()),
      nav_menu(
        "B. Preprocessing",
        # We can't put the download button easily in nav_menu directly as an item,
        # so we'll put it in a specific 'Dashboard' or 'Overview' panel if needed,
        # OR just keep it in the panels.
        # Let's create a dedicated panel for the report download within the menu.
        nav_panel("1. Bridge Selector", bridge_sample_ui()),
        nav_panel("2. Normalization", normalization_ui()),
        nav_panel("3. LOD", lod_integration_ui()),
        nav_panel("4. Outlier Detection", outlier_detection_ui()),
        nav_panel("5. Manual Exclusion", manual_exclusion_ui()),
        nav_panel(
          "6. Report Download",
          div(
            class = "p-4",
            h4("Preprocessing Report Generation"),
            p("Generate a comprehensive PDF documentation of all data cleaning and transformation steps."),
            downloadButton(
              "download_preprocessing_report",
              label = tagList(icon("file-pdf"), " Download Preprocessing Report (PDF)"),
              class = "btn-primary"
            )
          )
        )
      ),
      nav_menu(
        "C. Statistical Analysis",
        nav_panel("1. Descriptive Stats", descriptive_stats_ui()),
        nav_panel("2. Normality Test", normality_test_ui()),
        nav_panel("3. T-Test", ttest_ui()),
        nav_panel("4. Wilcoxon Test", wilcox_ui()),
        nav_panel("5. ANOVA", anova_ui()),
        nav_panel("6. ANOVA Post-hoc", anova_posthoc_ui()),
        nav_panel("7. Linear Mixed Effects", lme_stats_ui()),
        nav_panel("8. LME Post-hoc", lme_posthoc_ui())
      ),
      nav_menu(
        "D. Exploratory Analysis",
        nav_panel("1. PCA Plot", pca_plot_ui()),
        nav_panel("2. UMAP Plot", umap_ui())
      ),
      nav_menu(
        "E. Visualization",
        nav_panel("1. Box Plot", boxplot_ui()),
        nav_panel("2. Distribution Plot", distribution_plot_ui()),
        nav_panel("3. LME Plot", lme_plot_ui()),
        nav_panel("4. Pathway Heatmap", pathway_heatmap_ui()),
        nav_panel("5. QC Plot", qc_plot_ui()),
        nav_panel("6. Heatmap Plot", heatmap_ui()),
        nav_panel("7. Volcano Plot", volcano_plot_ui()),
        nav_panel("8. Violin Plot", violin_plot_ui())
      ),
      nav_panel("F. Pathway Enrichment", pathway_enrichment_ui()),
      nav_panel("G. Linear Regression", linear_regression_ui()),
      nav_panel("H. Analysis Report", analysis_report_ui())
    ),
    tags$footer(
      class = "footer mt-5",
      div(
        class = "container text-center",
        div(
          style = "margin-bottom: 1rem;",
          a(
            href = "https://github.com/JD2112/olinkWrapper", target = "_blank",
            class = "text-decoration-none mx-3 margin-right: 2rem",
            tagList(icon("github"), " GitHub Repository")
          ),
          a(
            href = "https://jd2112.github.io/olinkWrapper/latest/", target = "_blank",
            class = "text-decoration-none mx-3 margin-left: 2rem",
            tagList(icon("book"), " olinkWrapper Manual")
          )
        ),
        div(
          class = "text-muted",
          style = "font-size: 1.4rem;",
          p(paste0("©", format(Sys.Date(), "%Y"), " | Developed & maintained by Jyotirmoy Das")),
          p("Bioinformatics Unit, Core Facility & Clinical Genomics Linköping, Linköping University",
            style = "font-size: 1rem; opacity: 0.8;"
          )
        ),
        div(class = "mt-2", span(class = "badge bg-light text-dark", paste0("Version ", APP_VERSION)))
      )
    )
  )
}

ui <- single_ui()
server <- function(input, output, session) {}

shinyApp(ui, server)
