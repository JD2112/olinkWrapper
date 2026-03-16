#' Launch the olinkWrapper Shiny App
#'
#' @import OlinkAnalyze
#' @import tidyverse
#' @import msigdbr
#' @import viridis
#' @import writexl
#' @import ggrepel
#' @import patchwork
#' @import dplyr
#' @import umap
#' @rawNamespace import(bslib, except = bootstrap)
#' @rawNamespace import(broom, except = bootstrap)
#' @rawNamespace import(lmerTest, except = lmer)
#' @rawNamespace import(lme4, except = c(lmer, show))
#' @rawNamespace import(plotly, except = last_plot)
#' @rawNamespace import(ggplot2, except = last_plot)
#' @rawNamespace import(purrr, except = simplify)
#' @rawNamespace import(clusterProfiler, except = simplify)
#' @rawNamespace import(shiny, except = c(dataTableOutput, renderDataTable, runExample))
#' @rawNamespace import(DT, except = c(dataTableOutput, renderDataTable))
#' @rawNamespace import(shinyjs, except = runExample)
#' @importFrom bslib bootstrap
#' @importFrom lmerTest lmer
#' @importFrom plotly last_plot
#' @importFrom purrr simplify
#' @importFrom shiny dataTableOutput renderDataTable
#' @importFrom shinyjs runExample show
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @export
run_app <- function() {
  shiny::runApp(
    system.file("shiny", package = "olinkWrapper")
  )
}