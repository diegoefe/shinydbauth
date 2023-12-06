# run from current directory
dbf=../test.db3
rm -vf ${dbf}
sqlite3 ${dbf} < sqlite.sql
