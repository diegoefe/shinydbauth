#!/usr/bin/env bash
set -e

R -e "devtools::document('.')"
R -e "devtools::build('.')"
R -e "devtools::install('.')"