#!/usr/bin/env zsh
set -euo pipefail
setopt xtrace

. "${PY_VENV_MYENV}"/bin/activate
find "$1" -maxdepth 1 -name "*.qmd" -type f -print | while read -r filepath
do
  quarto render "${filepath}"
  # dir=$(dirname "${filepath}")
  # filename=$(basename "${filepath}")
  # cmd="rmarkdown::render('"
  # cmd+="${filename}"
  # cmd+="', output_dir='.', output_format='all')"

  # cd "${dir}"
  # R -e "${cmd}"
  # R -e "rmarkdown::render(\""${filepath}"\", output_dir=\""${dir}"\", output_format=\"all\")"
done
