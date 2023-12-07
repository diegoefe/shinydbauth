#!/usr/bin/env bash

# this makes subshels to silently fail, so we skip it
# set -e

pac=$(cat DESCRIPTION | grep Package | awk '{ print $2 }')
ver=$(cat DESCRIPTION | grep Version | awk '{ print $2 }')
# echo "[$pac] [$ver]"
tar="${pac}_${ver}.tar.gz"
lg="./${pac}.Rcheck/00check.log"

function cleanCheck() {
    rm -rf ${pac}.Rcheck
}

function cleanAll() {
    cleanCheck
    rm -f ${tar}
}

cleanAll
R -e "devtools::document('.')"
R CMD build .
# R CMD Rd2pdf .
R CMD check --as-cran ${tar}

status=`cat "${lg}" | grep "Status" | grep -v "1 NOTE"`
if [ -z "$status" ]
then
    echo "OK!"
    cleanCheck
else
    echo "status: [$status]"
fi