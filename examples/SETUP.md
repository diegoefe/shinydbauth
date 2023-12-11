### Setup

1. Open a terminal into this folder
1. Run setup_data.R to download demo data:
    ```bash
    $ Rscript setup_data.R
    ```
1. Choose database backend to use:
    1. For SQLite:
        1. Create test database:
            ```bash
            $ Rscript setup_sqlite.R
            ```
        1. Users and passwords:
            - gman/gman1
            - vari/varin
            - diegoefe/Pepe12
            - utgnac/pepe12
            - pepedoce/pepe12
            - utgchaco/utg1
    1. For PostgreSQL:
        1. Create a database and two functions:
            - fetch_user()
            - update_user()
           Use the signatures for **db_pg.R**'s queries
        1. Copy **sample-auth.R** to **auth.R** and set it up with correct values:
            ```bash
            $ cp sample-auth.R auth.R
            $ vim auth.R
            ```
1. Open **app.R** and follow SETUP instructions
1. Run the demo:
    - In windows:
        ```
        launch_in_browser.cmd
        ```
    - In Linux/*nix:
        ```bash
        $ ./launch_in_browser.sh
        ```
