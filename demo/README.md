### Demo instructions

1. Open a terminal (bash) into this directory.
1. Choose database backend to use:
    1. For SQLite:
        1. cd to "db" and run **mk_db.sh**
        1. look for users and passwords in **sqlite.sql**
    1. For PostgreSQL:
        1. Create a database and two functions:
            - fetch_user()
            - update_user()
           Use the signatures for **db_pg.R**'s queries
        1. Copy **sample-auth.R** to **auth.R** and set it up with correct values
1. Open **app.R** and follow its SETUP instructions
1. Run the demo:
    ```bash
    ./launch_in_browser.sh
    ```
