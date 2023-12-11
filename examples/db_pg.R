require(RPostgreSQL)
library(DBI)
library(glue)
library(stringr)

connect_db <- function() {
  source('auth.R')
  dbConnect(dbDriver("PostgreSQL"), dbname = db_name, 
            host = db_host, port = db_port,
            user = db_user, password = db_pass)
}

my_custom_check_creds <- function(user, password) {
  con <- connect_db()
  on.exit(dbDisconnect(con))
  phash <- hash_pass(password)
  req <- glue_sql("select * from userman.fetch_user({username}, {password}) as f(status boolean, user_data text)",
                  username = user, password = phash, .con = con)
  req <- dbSendQuery(con, req)
  row <- dbFetch(req)
  ok <- FALSE
  data <- row$user_data
  if(count(row)>0) {
    ok <- as.logical(row$status)
  }
  if(ok) {
    ss <- as.character(data)
    df <- fromJSON(ss)
    if(is.null(df$provincia)) {
      df$provincia <- NA
    }
    if(is.null(df$survey_user)) {
      df$survey_user <- NA
    }
    js <- toJSON(
      list(role = df$role,
           provincia = df$provincia,
           username = user,
           perms = df$perms,
           level = df$level,
           survey_user = df$survey_user
      )
    )
    ud <- list(data=js)
    list(result = TRUE, user_info = ud)
  } else {
    list(result = FALSE)
  }
}

my_custom_update_pwd <- function(user, old_pwd, new_pwd) {
  con <- connect_db()
  on.exit(dbDisconnect(con))
  
  pold <- hash_pass(old_pwd)
  pnew <- hash_pass(new_pwd)
  
  req <- glue_sql("SELECT userman.update_user({username}, {passold}, {passnew})",
                  username = user, passold = pold, passnew = pnew, .con = con)
  req <- dbSendQuery(con, req)
  rows <- dbFetch(req)
  return(list(result = rows=="ok"))
}

