#' Launch the olinkWrapper Shiny App
#'
#' @export
run_app <- function() {
  shiny::runApp(
    system.file("shiny", package = "olinkWrapper")
  )
}