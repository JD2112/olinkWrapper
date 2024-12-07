server <- function(input, output, session) {
  options(shiny.maxRequestSize=1000000*1024^2)
  
  # Reactive values to store data and results
  merged_data <- reactiveVal()
  ttest_results <- reactiveVal()
  anova_results <- reactiveVal()
  
  # Call individual server modules
  data_input_server(input, output, session, merged_data)
  data_preview_server(input, output, session, merged_data)
  descriptive_stats_server(input, output, session, merged_data)
  normality_test_server(input, output, session, merged_data)
  pca_plot_server(input, output, session, merged_data)
  ttest_server(input, output, session, merged_data, ttest_results)
  anova_server(input, output, session, merged_data, anova_results)
  volcano_plot_server(input, output, session, merged_data)
  violin_plot_server(input, output, session, merged_data)
}