[![version](http://www.r-pkg.org/badges/version/shinydbauth)](https://CRAN.R-project.org/package=shinydbauth)
[![cranlogs](http://cranlogs.r-pkg.org/badges/shinydbauth)](https://CRAN.R-project.org/package=shinydbauth)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- [![cran checks](https://cranchecks.info/badges/worst/shinydbauth)](https://cranchecks.info/pkgs/shinydbauth) -->

Simple authentification mechanism for single 'shiny' applications.

Provides a simple authentification and password change functionality are performed calling user provided functions that typically access some database backend.<br>
Source code of main applications is protected until authentication is successful.

> **ATENTION**: This project uses borrowed and modified (stripped and incomplete) code from [ShinyManager](https://github.com/datastorm-open/shinymanager/) which provides a more secure, extended, generic and completed authentication solution, please **use it instead for stable applications**.

### Installation

Install from CRAN with :

```r
install.packages("shinydbauth")
```

Or install development version from GitHub :

```r
remotes::install_github("diegoefe/shinydbauth")
```

### Demo application

Go [here](https://github.com/diegoefe/shinydbauth-demo)



### Available languages

- English
- Español

### Password validity period

Using ``options("shinydbauth.pwd_validity")``, you can set password validity period. It defaults to ``Inf``. You can specify for example ``options("shinydbauth.pwd_validity" = 90)`` if you want to force user changing password each 90 days.

### Failure limit

Using ``options("shinydbauth.pwd_failure_limit")``, you can set password failure limit. It defaults to Inf. You can specify for example ``options("shinydbauth.pwd_failure_limit" = 5)`` if you want to lock user account after 5 wrong password.


### Relevant R documentation

````
require(shinydbauth)

# shiny integration
?secure_app
?create_server
?auth_ui # ui definition


# change labels / language
 ?set_labels

````

### Customization

You can customize the module (css, image, language, ...).

````
?secure_app
?auth_ui
?set_labels
````
