# Source all server modules
source(file.path("server", "server_data_input.R"))
source(file.path("server", "server_anova.R"))
source(file.path("server", "server_data_preview.R"))
source(file.path("server", "server_descriptive_stats.R"))
source(file.path("server", "server_normality_test.R"))
source(file.path("server", "server_pca_plot.R"))
source(file.path("server", "server_ttest.R"))
source(file.path("server", "server_violin_plot.R"))
source(file.path("server", "server_volcano_plot.R"))
source(file.path("server", "server_outlier_detection.R"))
source(file.path("server", "server_enhanced_visualization.R"))
source(file.path("server", "server_normalization.R"))
source(file.path("server", "server_pathway_enrichment.R"))
source(file.path("server", "server_lod_integration.R"))
source(file.path("server", "server_heatmap.R"))
source(file.path("server", "server_umap.R"))
source(file.path("server", "server_bridge_sample.R"))
source(file.path("server", "server_wilcox.R"))
source(file.path("server", "server_anova_posthoc.R"))
source(file.path("server", "server_lme_stats.R"))
source(file.path("server", "server_lme_posthoc.R"))
source(file.path("server", "server_boxplot.R"))
source(file.path("server", "server_distribution_plot.R"))
source(file.path("server", "server_lme_plot.R"))
source(file.path("server", "server_pathway_heatmap.R"))
source(file.path("server", "server_qc_plot.R"))
source(file.path("server", "server_manual_exclusion.R"))
# source("server/server_plate_randomization.R")
source(file.path("server", "server_linear_regression.R"))
source(file.path("server", "server_preprocessing_report.R"))
source(file.path("server", "server_analysis_report.R"))

print("All server modules sourced")
print("server_lme.R sourced successfully")

server_main <- function(input, output, session, merged_data, var_key_merged, ttest_results, npx_data_2) {
  print("Server function started")
  options(shiny.maxRequestSize = 1000000 * 1024^2)

  # Reactive values to store data and results
  anova_results <- reactiveVal()
  lme_results <- reactiveVal()
  shared_enrichment_results <- reactiveVal()
  wilcox_results <- reactiveVal()
  exclusion_log <- reactiveVal(list()) # shared preprocessing audit log
  analysis_log <- reactiveVal(list()) # shared comprehensive analysis log

  print("About to call data_input_server")
  safe_call(data_input_server, input, output, session, merged_data, var_key_merged, npx_data_2)
  print("Finished calling data_input_server")

  # Call individual server modules
  safe_call(data_preview_server, input, output, session, merged_data, var_key_merged, exclusion_log)
  safe_call(manual_exclusion_server, input, output, session, merged_data, exclusion_log)
  safe_call(outlier_detection_server, input, output, session, merged_data, exclusion_log, analysis_log)
  safe_call(descriptive_stats_server, input, output, session, merged_data, analysis_log)
  safe_call(normality_test_server, input, output, session, merged_data, analysis_log)
  safe_call(normalization_server, input, output, session, merged_data, npx_data_2)
  safe_call(pca_plot_server, input, output, session, merged_data, analysis_log)
  safe_call(ttest_server, input, output, session, merged_data, ttest_results, analysis_log)
  safe_call(anova_server, input, output, session, merged_data, anova_results, analysis_log)

  # Volcano plot server returns a list with wilcox_results setter
  safe_call(volcano_plot_server, input, output, session, merged_data, ttest_results, anova_results, wilcox_results, analysis_log)
  safe_call(violin_plot_server, input, output, session, merged_data, analysis_log)
  safe_call(heatmap_server, input, output, session, merged_data, analysis_log)
  safe_call(umap_server, input, output, session, merged_data, analysis_log)
  safe_call(pathway_enrichment_server, input, output, session, merged_data, ttest_results, shared_enrichment_results, analysis_log)
  safe_call(lod_integration_server, input, output, session, merged_data, exclusion_log)
  safe_call(bridge_sample_server, input, output, session, merged_data, npx_data_2)
  safe_call(preprocessing_report_server, input, output, session, exclusion_log)

  # Wilcox server - pass the wilcox_results setter from volcano plot
  safe_call(wilcox_server, input, output, session, merged_data, wilcox_results, analysis_log)

  safe_call(anova_posthoc_server, input, output, session, merged_data, anova_results, analysis_log)
  safe_call(lme_posthoc_server, input, output, session, merged_data, lme_results, analysis_log)
  safe_call(lme_stats_server, input, output, session, merged_data, lme_results, analysis_log)
  safe_call(boxplot_server, input, output, session, merged_data, anova_results, ttest_results, analysis_log)
  safe_call(distribution_plot_server, input, output, session, merged_data, analysis_log)
  safe_call(lme_plot_server, input, output, session, merged_data, analysis_log)
  safe_call(pathway_heatmap_server, input, output, session, shared_enrichment_results, ttest_results, analysis_log)
  safe_call(qc_plot_server, input, output, session, merged_data, analysis_log)
  safe_call(linear_regression_server, input, output, session, merged_data, analysis_log)
  safe_call(analysis_report_server, input, output, session, analysis_log)
}
