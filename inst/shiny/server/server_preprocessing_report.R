preprocessing_report_server <- function(input, output, session, exclusion_log) {

  output$download_preprocessing_report <- downloadHandler(
    filename = function() {
      paste0("preprocessing_report_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      # Render in a temporary directory to avoid permission issues and path confusion
      temp_dir <- tempdir()
      temp_report <- file.path(temp_dir, "report.Rmd")
      
      # Copy the template to the temp directory
      template_path <- normalizePath(file.path("server", "preprocessing_report_template.Rmd"))
      file.copy(template_path, temp_report, overwrite = TRUE)
      
      # Get the absolute path to the logo
      logo_path <- normalizePath(file.path("www", "ppin.png"))
      
      rmarkdown::render(
        input       = temp_report,
        output_file = file,
        output_format = "pdf_document",
        params = list(
          exclusion_log = exclusion_log(),
          version = "1.3.0",
          img_path = logo_path
        ),
        envir  = new.env(parent = globalenv()),
        quiet  = TRUE
      )
    }
  )
}
