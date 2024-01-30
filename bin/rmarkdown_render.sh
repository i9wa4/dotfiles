#!/usr/bin/env bash
set -euo pipefail

find "$1" -maxdepth 1 -name "*.Rmd" -type f -print | while read -r filepath
do
  dir=$(dirname "${filepath}")
  filename=$(basename "${filepath}")
  cd "${dir}"
  cmd="rmarkdown::render('"
  cmd+="${filename}"
  cmd+="', output_dir='.', output_format='all')"
  R -e "${cmd}"
  # R -e "rmarkdown::render(\""${filepath}"\", output_dir=\""${dir}"\", output_format=\"all\")"
done
