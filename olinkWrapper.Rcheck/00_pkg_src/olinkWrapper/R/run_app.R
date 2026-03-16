#' Launch the olinkWrapper Shiny App
#'
#' @import shiny
#' @import bslib
#' @import OlinkAnalyze
#' @import tidyverse
#' @import msigdbr
#' @import plotly
#' @import viridis
#' @import writexl
#' @import lme4
#' @import lmerTest
#' @import shinyjs
#' @import DT
#' @import broom
#' @import purrr
#' @import ggrepel
#' @import patchwork
#' @import ggplot2
#' @import dplyr
#' @import umap
#' @import clusterProfiler
#' @importFrom bslib bootstrap
#' @importFrom lmerTest lmer
#' @importFrom plotly last_plot
#' @importFrom purrr simplify
#' @importFrom shiny dataTableOutput renderDataTable
#' @importFrom shinyjs runExample show
#' @export
run_app <- function() {
  shiny::runApp(
    system.file("shiny", package = "olinkWrapper")
  )
}