library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(jsonlite)
library(digest)
library(stringr)

# this function assumes a json string that starts with "$data\n"
get_user_data <- function(parseable) {
  # ud <- list(username="", provincia="", role="", perms=list(), level="", survey_user="")
  ud <- list(username="", provincia="", role="", perms="", level="", survey_user="")
  tryCatch(
    expr = {
      # skipping "$data\n"
      parseable <- substring(parseable, 6)
      ud <- fromJSON(parseable)
    },
    error = function(e){
      # message('Caught an error!')
      # message(e)
    },
    warning = function(w){
      # message(w)
    },
    finally = {
      # message('All done, quitting.')
    }
  )
  ud
}

hash_pass <- function(password) {
  digest(password, "sha256", serialize=FALSE)
}

render_user_info <- function(text) {
  renderInfoBox({
    infoBox(title = HTML("Info:<br>"),
            value = HTML("<span style='font-size:12px, text-align:center'>",
                         text,"</span>"),
            color = "blue",
            # fill = TRUE,
            width = 11
            # width = 15
    )})
}

