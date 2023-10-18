#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

find $1 -maxdepth 1 -name "*.Rmd" -type f -print | while read file
do
  dir="$(dirname "${file}")"
  R -e "rmarkdown::render(\""${file}"\", output_dir=\""${dir}"\", output_format=\"all\")"
done
