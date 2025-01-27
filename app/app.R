library(shiny)
library(bslib)
library(OlinkAnalyze)
library(tidyverse)
library(msigdbr)
library(plotly)
library(viridis)
library(writexl)
library(lme4)
library(lmerTest)
library(shinyjs)

# Source all your existing modules
source("ui/ui_main.R")
source("server/server_main.R")

# Source the new start page modules
source("ui/ui_startpage.R")
source("server/server_startpage.R")

# Define the main UI
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  uiOutput("page_content"),
  uiOutput("background_style")
)

# Define the main server
server <- function(input, output, session) {
  # Reactive value to store the current page
  current_page <- reactiveVal("start")
  
  # Render the appropriate page
  output$page_content <- renderUI({
    print(paste("Rendering page:", current_page()))
    if (current_page() == "start") {
      start_page_ui()
    } else {
      print("Rendering single panel UI")
      single_ui()
    }
  })
  
  # Render the background style
  output$background_style <- renderUI({
    if (current_page() == "start") {
      tags$style(HTML("
        body {
          background-image: url('ppin.gif');
          background-size: cover;
          background-repeat: no-repeat;
          background-attachment: fixed;
          height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .start-page-content {
          background-color: rgba(255, 255, 255, 0.8);
          padding: 30px;
          border-radius: 10px;
          text-align: center;
        }
        .radio-buttons-center {
          display: flex;
          flex-direction: column;
          align-items: center;
        }
        .radio-buttons-center .shiny-options-group {
          width: auto;
          padding-left: 80px; /* Add space on the left */
        }
        .radio-buttons-center .radio {
          text-align: left;
        }
        .radio-buttons-center .radio label {
          font-size: 18px; /* Make the text bigger */
          padding: 5px 0; /* Add some vertical padding */
        }
      "))
    } else {
      tags$style(HTML("
        body {
          background-image: none;
          background-color: #ffffff;
        }
      "))
    }
  })
  
  # Start page server logic
  observeEvent(input$start_analysis, {
    print("Start analysis button clicked")
    if (input$analysis_type == "single") {
      print("Switching to main page")
      current_page("main")
    } else {
      showNotification("Multi-panel analysis is not yet implemented.", type = "warning")
    }
  })
  
  # Main analysis server logic
  observeEvent(current_page(), {
    print(paste("Current page changed to:", current_page()))
    if (current_page() == "main") {
      print("Calling server_main function")
      server_main(input, output, session)
    }
  })
}

shinyApp(ui, server)