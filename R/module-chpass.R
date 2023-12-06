
#' Change password module
#'
#' @param id Module's id.
#' @param tag_img A \code{tags$img} to be displayed on the authentication module.
#' @param status Bootstrap status to use for the panel and the button.
#'  Valid status are: \code{"default"}, \code{"primary"}, \code{"success"},
#'  \code{"warning"}, \code{"danger"}.
#'
#' @export
#'
#' @name module-chpass
#'
#' @importFrom htmltools tagList singleton tags
#' @importFrom shiny NS fluidRow column passwordInput actionButton
#'
chpass_ui <- function(id, tag_img = NULL, status = "primary", lan = NULL) {

  ns <- NS(id)

  if(is.null(lan)){
    lan <- use_language()
  }

  tagList(
    singleton(tags$head(
      tags$link(href="shinydbauth/styles-auth.css", rel="stylesheet"),
      tags$script(src = "shinydbauth/bindEnter.js")
    )),
    
    tags$div(
      id = ns("pwd-mod"), class = "panel-auth",
      tags$br(), tags$div(style = "height: 0px;"), tags$br(),
      navbarPage(
      title = "",
      theme = theme,
      fluid = TRUE,
      header = tagList(
        tags$style(".navbar-header {margin-left: 16.66% !important;}"),
        fab_button(
          position = "bottom-right",
          actionButton(
            inputId = ".shinydbauth_logout",
            label = lan$get("Logout"),
            icon = icon("right-from-bracket")
          ),
          actionButton(
            inputId = ".shinydbauth_app",
            label = lan$get("Go to application"),
            icon = icon("share")
          )
        ),
        shinydbauth_where("chpass")
      ),
      tabPanel(
        fluidRow(
            column(
              width = 4, offset = 4,
              tags$div(
                class = paste0("panel panel-", status),
                tags$div(
                  class = "panel-body",
                  tags$div(
                    style = "text-align: center;",
                    if (!is.null(tag_img)) tag_img,
                    tags$h3(lan$get("Please change your password"))
                  ),
                  # tags$br(),
                  # textOutput(ns("text")),
                  tags$br(),
                  passwordInput(
                    inputId = ns("pwd_cur"),
                    label = lan$get("Current password:"),
                    width = "100%"
                  ),
                  passwordInput(
                    inputId = ns("pwd_one"),
                    label = lan$get("New password:"),
                    width = "100%"
                  ),
                  passwordInput(
                    inputId = ns("pwd_two"),
                    label = lan$get("Confirm password:"),
                    width = "100%"
                  ),
                  tags$span(
                    class = "help-block",
                    icon("circle-info"),
                    lan$get("Password must contain at least one number, one lowercase, one uppercase and must be at least length 6.")
                  ),
                  tags$br(),
                  tags$div(
                    id = ns("container-btn-update"),
                    actionButton(
                      inputId = ns("update_pwd"),
                      label = lan$get("Update new password"),
                      width = "100%",
                      class = paste0("btn-", status)
                    ),
                    tags$br(), tags$br()
                  ),
                  tags$script(
                    sprintf("bindEnter('%s');", ns(""))
                  ),
                  tags$div(id = ns("result_pwd"))
                )
              )
            )
          )
        )
      )
    )
  )
}

#' @param input,output,session Standard Shiny server arguments.
#' @param update_pupdate_credentials A \code{function} to perform an action when changing password is successful.
#'  Two arguments will be passed to the function: \code{user} (username) and \code{password}
#'  (the new password). Must return a list with at least a slot \code{result} with \code{TRUE}
#'  or \code{FALSE}, according if the update has been successful.
#' @param validate_pwd A \code{function} to validate the password enter by the user.
#'  Default is to check for the password to have at least one number, one lowercase,
#'  one uppercase and be of length 6 at least.
#' @param use_token Add a token in the URL to check authentication. Should not be used directly.
#' @param lan An language object. Should not be used directly.
#' 
#' @export
#'
#' @rdname module-chpass
#'
#' @importFrom htmltools tags
#' @importFrom shiny reactiveValues observeEvent removeUI insertUI icon actionButton
#' @importFrom utils getFromNamespace
chpass_server <- function(input, output, session, update_credentials, validate_pwd = NULL, 
                       use_token = FALSE, lan = NULL) {

  if(!is.reactive(lan)){
    if(is.null(lan)){
      lan <- reactive(use_language())
    } else {
      lan <- reactive(lan)
    }
  }

  observe({
    session$sendCustomMessage(
      type = "focus_input",
      message = list(inputId = ns("pwd_cur"))
    )
  })
  
  if (is.null(validate_pwd)) {
    validate_pwd <- getFromNamespace("validate_pwd", "shinydbauth")
  }

  ns <- session$ns
  jns <- function(x) {
    paste0("#", ns(x))
  }

  focus <- function(tid) {
    session$sendCustomMessage(
      type = "focus_input",
      message = list(inputId = ns(tid))
    )
  }

  fail <- function(lan_msg, focus_on) {
    print(paste("fail(", lan_msg, ",", focus_on, ")"))
    insertUI(
        selector = jns("result_pwd"),
        ui = tags$div(
          id = ns("msg_pwd"), class = "alert alert-danger",
          icon("triangle-exclamation"), lan()$get(lan_msg)
        ),
        focus(focus_on)
      )
  }

  fail_empty <- function(focus_on) {
    fail("Password must be defined", focus_on)
  }

  
  password <- reactiveValues(result = FALSE, user = NULL, relog = NULL)

  observeEvent(input$update_pwd, {
    password$relog <- NULL
    removeUI(selector = jns("msg_pwd"))

    if(input$pwd_cur == "") {
      fail_empty('pwd_cur')
    } else if(!isTruthy(input$pwd_one)) {
      fail_empty('pwd_one')
    } else if(!isTruthy(input$pwd_two)) {
      fail_empty('pwd_two')
    } else if (!identical(input$pwd_one, input$pwd_two)) {
      fail('The two passwords are different', 'pwd_one')
    } else if (identical(input$pwd_cur, input$pwd_one)) {
      fail('New password cannot be the same as old', 'pwd_cur')
    } else if (!isTRUE(validate_pwd(input$pwd_one))) {
      fail('Password does not respect safety requirements', 'pwd_one')
    } else {
      token <- getToken(session = session)
      user <- .tok$get_user(token)
      # print(paste("user?", user))
      res_pwd <- update_credentials(user, input$pwd_cur, input$pwd_one)
      if (isTRUE(res_pwd$result)) {
        password$result <- TRUE
        password$user <- user
        removeUI(selector = jns("container-btn-update"))
        insertUI(
          selector = jns("result_pwd"),
          ui = tags$div(
            id = ns("msg_pwd"),
            tags$div(
              class = "alert alert-success",
              icon("check"), lan()$get("Password successfully updated! Please re-login")
            ),
            actionButton(
              inputId = ns("relog"),
              label = lan()$get("Login"),
              width = "100%"
            )
          )
        )
      } else {
        insertUI(
          selector = jns("result_pwd"),
          ui = tags$div(
            id = ns("msg_pwd"), class = "alert alert-danger",
            icon("triangle-exclamation"), lan()$get("Failed to update password")
          )
        )
      }
    }
  }, ignoreInit = TRUE)

  observeEvent(input$relog, {
    if (isTRUE(use_token)) {
      token <- getToken(session = session)
      .tok$remove(token)
      # resetQueryString(session = session)
      # Resetting QS to avoid re-prompt for change password
      updateQueryString(queryString = sprintf("?token=\"%s\"&language=\"%s\"", token, lan()$get_language()), session = session, mode = "replace")
      session$reload()
    }
    password$relog <- input$relog
  }, ignoreInit = TRUE)

  return(password)
}




