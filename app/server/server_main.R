source(file.path("server", "server_data_input.R"))
source(file.path("server", "server_anova.R"))
source(file.path("server", "server_data_preview.R"))
source(file.path("server", "server_descriptive_stats.R"))
source(file.path("server", "server_normality_test.R"))
source(file.path("server", "server_pca_plot.R"))
source(file.path("server", "server_ttest.R"))
source(file.path("server", "server_violin_plot.R"))
source(file.path("server", "server_volcano_plot.R"))


print("Starting to source files")
source(file.path("server", "server_data_input.R"))
print("Finished sourcing server_data_input.R")

server <- function(input, output, session) {
  print("Server function started")
  options(shiny.maxRequestSize=1000000*1024^2)
  
  # Reactive values to store data and results
  merged_data <- reactiveVal()
  ttest_results <- reactiveVal()
  anova_results <- reactiveVal()
  
  print("About to call data_input_server")
  data_input_server(input, output, session, merged_data)
  print("Finished calling data_input_server")
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