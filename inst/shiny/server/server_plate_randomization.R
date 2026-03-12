library(OlinkAnalyze)
library(dplyr)

plate_randomization_server <- function(input, output, session, merged_data) {
  
  # Update fill color choices based on available columns in merged_data
  observe({
    req(merged_data())
    updateSelectInput(session, "plate_fill_color", choices = names(merged_data()))
  })
  
  # Generate plate layout
  plate_layout_data <- eventReactive(input$generate_plate_layout, {
    req(merged_data())
    
    tryCatch({
      print("Generating plate layout...")
      print(paste("Fill color variable:", input$plate_fill_color))
      
      # Extract necessary information from merged_data
      manifest <- merged_data() %>%
        select(SampleID, !!sym(input$plate_fill_color)) %>%
        distinct()
      
      print("Manifest data:")
      print(head(manifest))
      print(paste("Number of unique samples:", nrow(manifest)))
      
      # Run olink_plate_randomizer
      randomized_data <- tryCatch({
        olink_plate_randomizer(
          Manifest = manifest,
          PlateSize = as.numeric(input$plate_size),
          num_ctrl = input$num_ctrl,
          rand_ctrl = input$rand_ctrl
        )
      }, error = function(e) {
        print(paste("Error in olink_plate_randomizer:", e$message))
        return(NULL)
      })
      
      if (is.null(randomized_data)) {
        return(NULL)
      }
      
      print("Randomized data:")
      print(head(randomized_data))
      
      # Then, use the randomized data to display the plate layout
      olink_displayPlateLayout(
        data = randomized_data,
        fill.color = input$plate_fill_color,
        PlateSize = as.numeric(input$plate_size),
        num_ctrl = input$num_ctrl,
        rand_ctrl = input$rand_ctrl,
        Product = if(input$product != "") input$product else NULL,
        include.label = input$include_label
      )
    }, error = function(e) {
      print(paste("Error in plate randomization:", e$message))
      print("Merged data structure:")
      print(str(merged_data()))
      showNotification(paste("Error generating plate layout:", e$message), type = "error")
      NULL
    })
  })
  
  # Render plate layout plot
  output$plate_layout_plot <- renderPlot({
    req(plate_layout_data())
    print("Rendering plate layout plot...")
    plate_layout_data()
  })
  
  # Download handler
  output$download_plate_layout <- downloadHandler(
    filename = function() {
      paste("plate_layout_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      req(plate_layout_data())
      ggsave(file, plot = plate_layout_data(), device = "png", width = 12, height = 10)
    }
  )
}