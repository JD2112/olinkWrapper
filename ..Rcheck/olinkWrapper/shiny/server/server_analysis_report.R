# Optimized Analysis Report Server Logic
analysis_report_server <- function(input, output, session, analysis_log) {
  # App Version
  VERSION <- APP_VERSION  # Set globally by version.R

  # Analysis Preview Table (UI Component)
  output$analysis_log_preview <- renderTable(
    {
      log <- analysis_log()
      if (is.null(log) || length(log) == 0) {
        return(data.frame(
          "Timestamp" = character(0),
          "Analysis Step" = character(0),
          "Description" = character(0)
        ))
      }

      data.frame(
        "Timestamp"     = sapply(log, `[[`, "timestamp"),
        "Analysis Step" = sapply(log, `[[`, "step"),
        "Description"   = sapply(log, `[[`, "description")
      )
    },
    class = "table table-hover mb-0",
    striped = TRUE
  )

  # Optimized Download Handler
  output$download_analysis_report <- downloadHandler(
    filename = function() {
      paste0("olinkWrapper_v", VERSION, "_Report_", format(Sys.Date(), "%Y%m%d"), ".pdf")
    },
    content = function(file) {
      withProgress(message = "Compiling comprehensive report...", value = 0, {
        # Setup temporary environment for compilation
        temp_dir <- tempdir()
        temp_report <- file.path(temp_dir, "analysis_report.Rmd")
        temp_bib <- file.path(temp_dir, "references.bib")

        # Path resolution for assets
        template_path <- normalizePath(file.path("server", "analysis_report_template.Rmd"), mustWork = TRUE)
        bib_path <- normalizePath(file.path("www", "references.bib"), mustWork = FALSE)
        logo_path <- normalizePath(file.path("www", "ppin.png"), mustWork = FALSE)

        # Copy necessary files to temp directory
        file.copy(template_path, temp_report, overwrite = TRUE)
        if (file.exists(bib_path)) {
          file.copy(bib_path, temp_bib, overwrite = TRUE)
        }

        incProgress(0.5, detail = "Rendering via xelatex (Memory-Efficient Mode)")

        # Render the PDF
        # We pass the log which now contains file paths instead of ggplot objects
        rmarkdown::render(
          input = temp_report,
          output_file = file,
          params = list(
            analysis_log = analysis_log(),
            version = VERSION,
            img_path = logo_path
          ),
          envir = new.env(parent = globalenv()),
          quiet = TRUE
        )

        incProgress(0.5, detail = "Finalizing PDF document")
      })
    }
  )
}

# Optimized logging function
# Call this inside your analysis modules to save progress
log_analysis <- function(analysis_log, step, description, plot = NULL, table = NULL) {
  current_log <- analysis_log()

  # 1. SAVE PLOT TO DISK IMMEDIATELY
  # This is the most important step to save RAM.
  plot_path <- NULL
  if (!is.null(plot)) {
    # Create a unique filename for this step
    plot_path <- tempfile(pattern = paste0("step_", length(current_log) + 1, "_"), fileext = ".png")

    try(
      {
        # Handle different plot types
        if (inherits(plot, "ggplot") || inherits(plot, "recordedplot")) {
          ggplot2::ggsave(plot_path, plot = plot, width = 10, height = 7, dpi = 300)
        } else if (inherits(plot, "Heatmap") || inherits(plot, "ComplexHeatmap")) {
          png(plot_path, width = 10, height = 7, units = "in", res = 300)
          print(plot)
          dev.off()
        } else {
          # Fallback for other plot objects
          png(plot_path, width = 10, height = 7, units = "in", res = 300)
          print(plot)
          dev.off()
        }
      },
      silent = TRUE
    )
  }

  # 2. PRUNE TABLE DATA
  # Only store the preview rows in the log to avoid memory bloat
  formatted_table <- if (!is.null(table)) {
    as.data.frame(head(table, 25))
  } else {
    NULL
  }

  # 3. CONSTRUCT LIGHTWEIGHT LOG ENTRY
  current_log[[length(current_log) + 1]] <- list(
    step = step,
    description = description,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    plot_path = plot_path, # Store the STRING path, not the object
    table = formatted_table
  )

  # Update reactiveVal
  analysis_log(current_log)
  return(analysis_log)
}
