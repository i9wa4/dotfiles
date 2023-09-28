#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

filelist="$(find $1 -maxdepth 2 -name "*.Rmd" -type f -print)"

for file in "$(filelist)"; do
  dir="$(dirname "${file}")"
  R -e "rmarkdown::render(\""${file}"\", output_dir=\""${dir}"\")"
done
