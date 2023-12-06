#' Adds the content of inst/assets/ to shinydbauth/
#'
#' @importFrom shiny addResourcePath
#'
#' @noRd
#'
.onLoad <- function(...) {
  shiny::addResourcePath("shinydbauth", system.file("assets", package = "shinydbauth"))
}
