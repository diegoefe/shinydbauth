
#' Secure a Shiny application and manage authentication
#'
#' @param ui UI of the application.
#' @param ... Arguments passed to \code{\link{auth_ui}}.
#' @param head_auth Tag or list of tags to use in the \code{<head>}
#'  of the authentication page (for custom CSS for example).
#' @param theme Alternative Bootstrap stylesheet, default is to use \code{readable},
#'  you can use themes provided by \code{shinythemes}.
#'  It will affect the authentication panel and the admin page.
#' @param language Language to use for labels, supported values are : "en", "es".
#' @param fab_position Position for the FAB button, see \code{\link{fab_button}} for options.
#'
#' @note A special input value will be accessible server-side with \code{input$shinydbauth_where}
#'  to know in which step user is : authentication, application, admin or password.
#'
#' @return A \code{reactiveValues} containing informations about the user connected.
#'
#' @export
#'
#' @importFrom shiny parseQueryString fluidPage actionButton icon navbarPage tabPanel
#' @importFrom htmltools tagList
#'
#' @name secure-app
#'
secure_app <- function(ui,
                       ...,
                       head_auth = NULL,
                       theme = NULL,
                       language = "en",
                       fab_position = "bottom-right") {
  if (!language %in% c("en", "es")) {
    warning("Only supported language for the now are: en, es", call. = FALSE)
    language <- "en"
  }

  lan <- use_language(language)
  ui <- force(ui)
  head_auth <- force(head_auth)
  if (is.null(theme)) {
    theme <- "shinydbauth/css/readable.min.css"
  }

  function(request) {
    query <- parseQueryString(request$QUERY_STRING)
    # print(paste("query", query))
    token <- gsub('\"', "", query$token)
    admin <- query$admin
    language <- query$language
    if (!is.null(language)) {
      lan <- use_language(gsub('\"', "", language))
    }
    if (.tok$is_valid(token)) {
      change_pass <- query$chp
      if(!is.null(change_pass)) {
        args <- get_args(..., fun = chpass_ui)
        args$id <- "chpass"
        args$lan <- lan
        chpass_ui <- fluidPage(
          theme = theme,
          tags$head(head_auth),
          do.call(chpass_ui, args),
          shinydbauth_where("chpass"),
          shinydbauth_language(lan$get_language())
        )
        return(chpass_ui)
      }
      
      menu <- fab_button(
        position = fab_position,
        actionButton(
          inputId = ".shinydbauth_logout",
          label = lan$get("Logout"),
          icon = icon("right-from-bracket")
        ),
        actionButton(
          inputId = ".shinydbauth_chpass",
          label = lan$get("Password"),
          icon = icon("key")
        )
      )
        
        if (is.function(ui)) {
          ui <- ui(request)
        }
        tagList(
          ui, menu, shinydbauth_where("application"),
          shinydbauth_language(lan$get_language()),
          singleton(tags$head(tags$script(src = "shinydbauth/timeout.js")))
        )
      
    } else {
      args <- get_args(..., fun = auth_ui)
      # patch / message changing tag_img & tag_div
      deprecated <- list(...)
      if ("tag_img" %in% names(deprecated)) {
        args$tags_top <- deprecated$tag_img
        warning("'tag_img' (auth_ui, secure_app) is now deprecated. Please use 'tags_top'", call. = FALSE)
      }
      if ("tag_div" %in% names(deprecated)) {
        args$tags_bottom <- deprecated$tag_div
        warning("'tag_div' (auth_ui, secure_app) is now deprecated. Please use 'tags_bottom'", call. = FALSE)
      }
      args$id <- "auth"
      args$lan <- lan
      fluidPage(
        theme = theme,
        tags$head(head_auth),
        do.call(auth_ui, args),
        shinydbauth_where("authentication"),
        shinydbauth_language(lan$get_language())
      )
    }
  }
}


#' @param check_credentials Function passed to \code{\link{auth_server}}.
#' @param timeout Timeout session (minutes) before logout if sleeping. Defaut to 15. 0 to disable.
#' @param inputs_list \code{list}. If database credentials, you can configure inputs for editing users information. See Details.
#' @param keep_token Logical, keep the token used to authenticate in the URL, it allow to refresh the
#'  application in the browser, but careful the token can be shared between users ! Default to \code{FALSE}.
#' @param validate_pwd A \code{function} to validate the password enter by the user.
#'  Default is to check for the password to have at least one number, one lowercase,
#'  one uppercase and be of length 6 at least.
#' @param session Shiny session.
#'
#' @details
#'
#' If database credentials, you can configure inputs with \code{inputs_list} for editing users information
#' from the admin console. \code{start}, \code{expire}, \code{admin} and \code{password} are not configurable.
#' The others columns are rendering by defaut using a \code{textInput}. You can modify this using \code{inputs_list}.
#' \code{inputs_list} must be a named list. Each name must be a column name, and then we must have the function
#'  shiny to call \code{fun} and the arguments \code{args} like this :
#'  \code{
#'  list(group = list(
#'      fun = "selectInput",
#'      args = list(
#'          choices = c("all", "restricted"),
#'          multiple = TRUE,
#'          selected = c("all", "restricted")
#'       )
#'      )
#' )
#' }
#'
#' You can specify if you want to allow downloading users file,  sqlite database and logs from within
#' the admin panel by invoking \code{options("shinydbauth.download")}. It defaults
#' to \code{c("db", "logs", "users")}, that allows downloading all. You can specify
#' \code{options("shinydbauth.download" = "db"} if you want allow admin to download only
#' sqlite database, \code{options("shinydbauth.download" = "logs")} to allow logs download
#' or \code{options("shinydbauth.download" = "")} to disable all.
#'
#' Using \code{options("shinydbauth.pwd_validity")}, you can set password validity period. It defaults
#' to \code{Inf}. You can specify for example
#' \code{options("shinydbauth.pwd_validity" = 90)} if you want to force user changing password each 90 days.
#'
#' Using \code{options("shinydbauth.pwd_failure_limit")}, you can set password failure limit. It defaults
#' to \code{Inf}. You can specify for example
#' \code{options("shinydbauth.pwd_failure_limit" = 5)} if you want to lock user account after 5 wrong password.
#'
#'
#' @export
#'
#' @importFrom shiny callModule getQueryString parseQueryString
#'  updateQueryString observe getDefaultReactiveDomain isolate invalidateLater
#'
#' @rdname secure-app
secure_server <- function(check_credentials,
                          timeout = 15,
                          inputs_list = NULL,
                          keep_token = FALSE,
                          validate_pwd = NULL,
                          update_credentials = NULL,
                          session = shiny::getDefaultReactiveDomain()) {

  session$setBookmarkExclude(c(session$getBookmarkExclude(),
                               "shinydbauth_language",
                               ".shinydbauth_timeout",
                               ".shinydbauth_logout",
                               "shinydbauth_where"))


  token_start <- isolate(getToken(session = session))

  if (isTRUE(keep_token)) {
    .tok$reset_count(token_start)
  } else {
    isolate(resetQueryString(session = session))
  }

  lan <- reactiveVal(use_language())
  observe({
    lang <- getLanguage(session = session)
    if (!is.null(lang)) {
      lan(use_language(lang))
    }
  })

  auth_rv <- callModule(
    module = auth_server,
    id = "auth",
    check_credentials = check_credentials,
    use_token = TRUE,
    lan = lan
  )

  if(!is.null(update_credentials)) {
    callModule(
      module = chpass_server,
      id = "chpass",
      update_credentials = update_credentials,
      validate_pwd = validate_pwd,
      use_token = TRUE,
      lan = lan
    )
  }

  .tok$set_timeout(timeout)

  user_info_rv <- reactiveValues()

  observe({
    token <- getToken(session = session)
    if (!is.null(token)) {
      user_info <- .tok$get(token)
      for (i in names(user_info)) {
        value <- user_info[[i]]
        if (i %in% "applications") {
          value <- strsplit(x = as.character(value), split = ";")
          value <- unlist(x = value, use.names = FALSE)
        } else if (!is.null(inputs_list)) {
          if (i %in% names(inputs_list) && !is.null(inputs_list[[i]]$args$multiple) && inputs_list[[i]]$args$multiple) {
            value <- strsplit(x = as.character(value), split = ";")
            value <- unlist(x = value, use.names = FALSE)
          }
        }
        user_info_rv[[i]] <- value
      }
    }
  })

  observeEvent(session$input$.shinydbauth_app, {
    token <- getToken(session = session)
    updateQueryString(queryString = sprintf("?token=\"%s\"&language=\"%s\"", token, lan()$get_language()), session = session, mode = "replace")
    .tok$reset_count(token)
    session$reload()
  }, ignoreInit = TRUE)

  observeEvent(session$input$.shinydbauth_logout, {
    token <- getToken(session = session)
    .tok$remove(token)
    clearQueryString(session = session)
    session$reload() 
  }, ignoreInit = TRUE)

  observeEvent(session$input$.shinydbauth_chpass, {
    token <- getToken(session = session)
    updateQueryString(queryString = sprintf("?token=\"%s\"&language=\"%s\"&chp=1", token, lan()$get_language()), session = session, mode = "replace")
    .tok$reset_count(token)    
    session$reload()
  }, ignoreInit = TRUE)


  if (timeout > 0) {

    observeEvent(session$input$.shinydbauth_timeout, {
      token <- getToken(session = session)
      if (!is.null(token)) {
        valid_timeout <- .tok$is_valid_timeout(token, update = TRUE)
        if (!valid_timeout) {
          .tok$remove(token)
          clearQueryString(session = session)
          session$reload()
        }
      }
    })

    observe({
      invalidateLater(30000, session)
      token <- getToken(session = session)
      if (!is.null(token)) {
        valid_timeout <- .tok$is_valid_timeout(token, update = FALSE)
        if(!valid_timeout){
          .tok$remove(token)
          clearQueryString(session = session)
          session$reload()
        }
      }
    })

  }

  return(user_info_rv)
}

#' @param check_credentials Function passed to \code{\link{auth_server}}.
#' @param update_credentials Function passed to \code{\link{chpass_server}}.
#' @param server_fn Function that returns the authenticated server.
#'
#' @details
#' 
#' \code{\link{create_server}} calls \code{\link{secure_server}} and, if authentication is ok, passes user_info to server_fn
#'
#' @export
#'
#' @rdname secure-app
create_server <- function(check_credentials, update_credentials, server_fn) {
  server <- function(input, output, session) {
    res_auth <- secure_server(check_credentials=check_credentials, update_credentials=update_credentials)  
    auth <- renderPrint({
      isolate(reactiveValuesToList(res_auth))
    })
    
    observe({
      server_fn(auth(), input, output, session)
    })
  }
  server
}