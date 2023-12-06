require(RSQLite)
library(DBI)
library(glue)

connect_db <- function() {
  dbConnect(RSQLite::SQLite(), 'test.db3')
}

my_custom_check_creds <- function(user, password) {
  con <- connect_db()
  on.exit(dbDisconnect(con))
  phash <- hash_pass(password)
  # print(paste("username", user))
  # print(paste("password", password))
  # print(paste("phash", phash))
  req <- glue_sql("SELECT
  u.role,
  u.provincia,
  group_concat(p.perm_name, '|') perms,
  r.level,
  u.survey_user
FROM users u
  INNER JOIN roles r ON(u.role=r.role_name)
  INNER JOIN roles_perms rp ON(r.id=rp.id_role)
  INNER JOIN perms p ON(p.id=rp.id_perm)
WHERE username = {username}
  AND password = {password}
  AND is_locked=false
GROUP BY 1, 2, 4, 5", username = user, password = phash, .con = con)

  # print(paste("req", req))
  rows <- dbGetQuery(con, req)
  # print(paste("rows", rows))
  if (nrow(rows) > 0) {
    # str(rows)
    # print(paste("GOT rows", class(rows), rows))
    ss <- paste0('(', gsub("NA", "", as.character(paste(rows, collapse=","))), ')')
    # print(paste("GOT ss1", ss))
    # ss <- as.character(rows)
    # print(paste("ss", ss))
    len <- nchar(ss)
    # print(paste("nchar", len))
    # remuevo ( y )
    fix <- substring(ss, 2, len -1)
    # print(paste("rows fix", typeof(fix), fix))
    res <- strsplit(fix, ",")
    
    df <- read.table(text = fix, sep = ",")
    colnames(df) <- c("role", "provincia", "perms", "level", "survey_user")
    # print(df)
    # print(paste("PERMS", df$perms, sep="'"))
    
    js <- toJSON(
      list(role = df$role,
           provincia = df$provincia,
           username = user,
           perms = df$perms,
           level = df$level,
           survey_user = df$survey_user
      )
    )
    # print(paste("js", js))
    ud <- list(data=js)
    list(result = TRUE, user_info = ud)
  } else {
    list(result = FALSE)
  }
}

my_custom_update_pwd <- function(user, old_pwd, new_pwd) {
  con <- connect_db()
  on.exit(dbDisconnect(con))
  
  # print(paste("username", user))
  # print(paste("pass_old", old_pwd))
  # print(paste("pass_new", new_pwd))
  
  pold <- hash_pass(old_pwd)
  pnew <- hash_pass(new_pwd)
  # print(paste("pold", pold))
  # print(paste("pnew", pnew))
  
  req <- glue_sql("SELECT 1 FROM users WHERE username = {username}", username = user, password = pold, .con = con)
  rows <- dbGetQuery(con, req)
  # print(paste("sel update", rows))
  if(rows=="1") {
    req <- glue_sql("update users set password = {passnew} where username = {username}",
                    username = user, passnew = pnew, .con = con)
    # print(paste("req", req))
    req <- dbSendQuery(con, req)
    nr = dbGetRowsAffected(req)
    # print(paste("nr", nr))
    dbClearResult(req)
    return(list(result = nr==1))
  }
  return(list(result = FALSE))
}
