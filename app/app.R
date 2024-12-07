library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
library(OlinkAnalyze)
library(readr)
library(writexl)
library(gridExtra)

# Source UI components
source("ui/ui_main.R")

# Source server components
source("server/server_main.R")

# Run the application
shinyApp(ui = ui, server = server)