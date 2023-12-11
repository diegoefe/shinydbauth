db_name = "mydatabase"
isRStudio <- Sys.getenv("RSTUDIO") == "1"
if(isRStudio) {
  db_host = "localhost"  
} else {
  db_host = "ipOrHostName"
}
db_port = 5432
db_user = "myuser"
db_pass = "mypassword"
