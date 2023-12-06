get_appname <- function() {
  getOption("shinydbauth.application", default = basename(getwd()))
}

get_download <- function(){
  getOption("shinydbauth.download", default = c("db", "logs", "users"))
}

get_pwd_validity <- function(){
  getOption("shinydbauth.pwd_validity", default = Inf)
}

get_pwd_failure_limit <- function(){
  getOption("shinydbauth.pwd_failure_limit", default = Inf)
}


get_args <- function(..., fun) {
  args_fun <- names(formals(fun))
  args <- list(...)
  args[names(args) %in% args_fun]
}

#' @importFrom R.utils capitalize
make_title <- function(x) {
  capitalize(gsub(
    pattern = "_", replacement = " ", x = x
  ))
}

dropFalse <- function(x) {
  isFALSE <- Negate(isTRUE)
  x[!vapply(x, isFALSE, FUN.VALUE = logical(1))]
}

validate_pwd <- function(pwd) {
  all(vapply(
    X = c("[0-9]+", "[a-z]+", "[A-Z]+", ".{6,}"),
    FUN = grepl, x = pwd, FUN.VALUE = logical(1)
  ))
}




