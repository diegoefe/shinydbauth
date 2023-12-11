require(RSQLite)
library(DBI)
library(glue)
library(stringr)

testDB <- "test.db3"

if(file.exists(testDB)) {
    stop("Database '", testDB, "' already exists!", call. = FALSE)
}

sql_file <- 'sqlite.sql'
sql_data <- readChar(sql_file, file.info(sql_file)$size)
all_sql <- strsplit(sql_data, ";")
sqls <- vector(mode='character')
for (s in all_sql) {
    sqls <- append(sqls, s)
}
# warnings()
# filter empty SQLs
sqls <- sqls <- sqls[sqls != "\n"]

conn <- dbConnect(SQLite(), dbname = testDB, flags = RSQLite::SQLITE_RWC)
on.exit(dbDisconnect(conn))
for(sql in sqls) {
    dbExecute(conn, sql)
}
