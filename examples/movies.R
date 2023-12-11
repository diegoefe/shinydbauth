# Load packages ----------------------------------------------------------------

library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(stringi)
library(shinydashboard)

source('common.R')

options("shiny.sanitize.errors" = FALSE) # Turn off error sanitization

# Load data --------------------------------------------------------------------
load("movies.RData")

n_total <- nrow(movies)
all_studios <- sort(unique(movies$studio))
min_date <- min(movies$thtr_rel_date)
max_date <- max(movies$thtr_rel_date)
# ratio of critics and audience scores
movies <- movies %>%
  mutate(score_ratio = audience_score / critics_score)

# Define UI --------------------------------------------------------------------

my_create_ui <- function() {
  ui <- fluidPage(
    titlePanel("Movie browser, 1970 to 2014", windowTitle = "Movies"),
    sidebarLayout(
      position = "right",    
      # Inputs: Select variables to plot
      conditionalPanel(
        condition = "input.lostabs == 'Plot'",
        sidebarPanel(
          HTML(paste0("Movies released between the following dates will be plotted. 
                      Pick dates between ", min_date, " and ", max_date, ".")),
          
          br(), br(),
          
          dateRangeInput(
            inputId = "date",
            label = "Select dates:",
            start = "2013-01-01", end = "2014-01-01",
            min = min_date, max = max_date,
            startview = "year"
          ),
          
          HTML(paste("Enter a value between 1 and", n_total)),
          numericInput(
            inputId = "n",
            label = "Sample size:",
            value = 30,
            min = 1, max = n_total,
            step = 1
          ),
          
          selectInput(
            inputId = "studio",
            label = "Select studio:",
            choices = all_studios,
            selected = "20th Century Fox",
            multiple = TRUE
          ),
          
          # Select variable for y-axis
          selectInput(
            inputId = "y",
            label = "Y-axis:",
            choices = c(
              "IMDB rating" = "imdb_rating",
              "IMDB number of votes" = "imdb_num_votes",
              "Critics score" = "critics_score",
              "Audience score" = "audience_score",
              "Runtime" = "runtime"
            ),
            selected = "audience_score"
          ),
          # Subset for title types
          checkboxGroupInput(inputId = "selected_title_type", 
                             label = "Select title type:", 
                             choices = levels(movies$title_type),
                             selected = levels(movies$title_type)),
          
          # Select variable for x-axis
          selectInput(
            inputId = "x",
            label = "X-axis:",
            choices = c(
              "IMDB rating" = "imdb_rating",
              "IMDB number of votes" = "imdb_num_votes",
              "Critics score" = "critics_score",
              "Audience score" = "audience_score",
              "Runtime" = "runtime"
            ),
            selected = "critics_score"
          ),
          
          # Select variable for color
          selectInput(
            inputId = "z",
            label = "Color by:",
            choices = c(
              "Title type" = "title_type",
              "Genre" = "genre",
              "MPAA rating" = "mpaa_rating",
              "Critics rating" = "critics_rating",
              "Audience rating" = "audience_rating"
            ),
            selected = "mpaa_rating"
          ),
          
          # sliderInput(
          #   inputId = "alpha",
          #   label = "Alpha:",
          #   min = 0, max = 1,
          #   value = 0.5
          # ),
          
          # Show data table
          checkboxInput(inputId = "show_data",
                        label = "Show data table", 
                        value = TRUE)
        )
      ),
      
      # Output: Show scatterplot
      mainPanel(
        # Display number of observations
        HTML(paste0("The dataset has ", nrow(movies), 
                    " observations.")),
        
        
        tabsetPanel(
          id = "lostabs",
          type = "tabs",
          tabPanel("Plot", 
                   plotOutput(outputId = "scatterplot", brush = "plot_brush"),
                   # plotOutput(outputId = "scatterplot", hover = "plot_hover"),
                   dataTableOutput(outputId = "moviestable"),
                   textOutput(outputId = "correlation"),
                   plotOutput(outputId = "densityplot", height = 200),
          ),
          # tabPanel("Summary", tableOutput(outputId = "summarytable"),),
          # tabPanel("Data", dataTableOutput(outputId = "moviestable_old"),),
          tabPanel(
            "Reference",
            tags$p(
              "There data were obtained from",
              tags$a("IMDB", href = "http://www.imdb.com/"), "and",
              tags$a("Rotten Tomatoes", href = "https://www.rottentomatoes.com/"), "."
            ),
            tags$p(
              "The data represent", nrow(movies),
              "randomly sampled movies released between 1972 to 2014 in the United States."
            )
          ),
          tabPanel(
            "User",
            infoBoxOutput("user_info")
          )
        )
      )
    )
    
  )
  ui
}

my_server_function <- function(user_data, input, output, session) {
  ud <- get_user_data(user_data)
  prov <- ud$provincia
  if(is.na(prov)) {
    prov = 'none'
  }
  survey_user <- ud$survey_user
  if(is.na(survey_user)) {
    survey_user = 'none'
  }
  level <- ud$level
  output$user_info <- render_user_info(
    paste0('Username: <b>', ud$username, '</b><br>',
          'Role: ', ud$role, '<br>',
          'Level: ', level, '<br>',
          'Province: ', prov, '<br>',
          'Permissions: ','<br><ul><li>', gsub("\\|", "</li><li>", ud$perms), '</li></ul>',
          'Survey user: ', survey_user
    )
  )
  calidad <- stri_detect_fixed(ud$perms, "calidad", max_count = 1)
  campo <- stri_detect_fixed(ud$perms, "seguimiento_campo", max_count = 1)
  cobertura <- stri_detect_fixed(ud$perms, "monitoreo_cobertura_gestion", max_count = 1)

  output$scatterplot <- renderPlot({
    req(input$date)
    movies_selected_date <- movies %>%
      filter(thtr_rel_date >= as.POSIXct(input$date[1]) & thtr_rel_date <= as.POSIXct(input$date[2]))
      # ggplot(data = movies_selected_date, aes_string(x = input$x, y = input$y, color = input$z)) + geom_point()
      ggplot(data = movies_selected_date, aes(x = .data[[input$x]], y = .data[[input$y]], color = .data[[input$z]])) + geom_point()
  })
  
  
  if(level>=80 && cobertura) {
    insertTab(inputId="lostabs", tab = tabPanel("Summary", tableOutput(outputId = "summarytable")), target="Plot")
    insertTab(inputId="lostabs", tab = tabPanel("Data", dataTableOutput(outputId = "moviestable_old")), target="Summary")
    output$summarytable <- renderTable(
      {
        movies %>%
          filter(title_type %in% input$selected_title_type) %>%
          group_by(mpaa_rating) %>%
          summarise(mean_score_ratio = mean(score_ratio), SD = sd(score_ratio), n = n())
      },
      striped = TRUE,
      spacing = "l",
      align = "lccr",
      digits = 4,
      width = "90%",
      caption = "Score ratio (audience / critics' scores) summary statistics by MPAA rating."
    )
    
    output$moviestable_old <- renderDataTable({
      req(input$studio)
      movies_from_selected_studios <- movies %>%
        filter(studio %in% input$studio) %>%
        select(title:studio)
      DT::datatable(
        data = movies_from_selected_studios,
        options = list(pageLength = 10),
        rownames = FALSE
      )
    })
  } else {
    # hideTab(inputId="lostabs", target = "Summary")
    # hideTab(inputId="lostabs", target = "Data")
  }

  txt_correlation <- renderText({
    r <- round(cor(movies[, input$x], movies[, input$y], use = "pairwise"), 3)
    paste0(
      "Correlation = ", r,
      ". Note: If the relationship between the two variables is not linear, the correlation coefficient will not be meaningful."
    )
  })
  plot_densityplot <- renderPlot({
    ggplot(data = movies, aes(x = .data[[input$x]])) + geom_density()
  })
  if(level>=100) {
    output$moviestable <- renderDataTable({
      brushedPoints(movies, input$plot_brush) %>%
        select(title, audience_score, critics_score)
    })
    output$correlation <- txt_correlation
    output$densityplot <- plot_densityplot
  } else {
    if(calidad) {
      output$correlation <- txt_correlation
    }
    if(campo) {
      output$densityplot <- plot_densityplot
    }
  }
  


}
