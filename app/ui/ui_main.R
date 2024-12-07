ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  tags$head(
    tags$style(HTML("
      body {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
      }
      .footer {
        margin-top: auto;
      }
      .footer-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .footer-section {
        flex: 1;
        text-align: center;
      }
      .footer-left {
        text-align: left;
      }
      .footer-right {
        text-align: right;
      }
      .initially-hidden {
        display: none;
      }
    "))
  ),
  
  h1("ShinyOlink: Shiny Interface for Olink Data Analysis", class = "text-center mb-4"),
  
  sidebar = data_input_ui(),
  
  navset_tab(
    nav_panel("Data Preview", data_preview_ui()),
    nav_panel("Descriptive Statistics", descriptive_stats_ui()),
    nav_panel("Normality Test", normality_test_ui()),
    nav_panel("PCA Plot", pca_plot_ui()),
    nav_panel("T-Test", ttest_ui()),
    nav_panel("ANOVA", anova_ui()),
    nav_panel("Volcano Plot", volcano_plot_ui()),
    nav_panel("Violin Plot", violin_plot_ui())
  ),
  
  div(
    class = "footer mt-auto py-3 bg-light",
    div(
      class = "container footer-content",
      div(
        class = "footer-section footer-left",
        "©2024, Jyotirmoy Das, Bioinformactics Unit, Core Facility & Clinical Genomics Linköping, Linköping University"
      ),
      div(
        class = "footer-section",
        a("GitHub repo: ShinyOlink", href = "https://github.com/JD2112/ShinyOlink", target = "_blank")
      ),
      div(
        class = "footer-section footer-right",
        "Version 1.0"
      )
    )
  )
)