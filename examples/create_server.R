if (interactive()) {

library(shiny)
library(shinydbauth)

my_custom_check_creds <- function(user, password) {
  if(user=="test" && password=="me") {
    list(result = TRUE, user_info = list())
  } else {
    list(result = FALSE)
  }
}

my_create_ui <- function() {
  ui <- fluidPage(
    titlePanel("Movie browser, 1970 to 2014", windowTitle = "Movies"),
      # Output: Show scatterplot
      mainPanel(
        tabsetPanel(
          id = "lostabs",
          type = "tabs",
          tabPanel(
            "User",
            verbatimTextOutput('user_info')
          )
        )
      )
  )
  ui
}

my_server_function <- function(user_data, input, output, session) {
  # ignoring user_data, faking it
  ud = data.frame(
    username="tester",
    role="coordinador_nacional",
    perms="seguimiento_campo|monitoreo_cobertura_gestion|calidad"
  )
  prov <- "none"
  survey_user <- "none"
  level <- 100
  output$user_info <- renderText(
    HTML(paste0('Username: ', ud$username, '\n',
          'Role: ', ud$role, '\n',
          'Level: ', level, '\n',
          'Province: ', prov, '\n',
          'Permissions: ','\n  ', gsub("\\|", "\n  ", ud$perms), '\n',
          'Survey user: ', survey_user
    ))
  )
  

}


ui <- my_create_ui()
ui <- secure_app(ui, language="es")
shinyApp(ui, create_server(my_custom_check_creds, my_custom_update_pwd, my_server_function))


}

