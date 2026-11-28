#!/usr/bin/env bash
set -euo pipefail

gh_bin="${PANEPALS_GH:-gh}"
jq_bin="${PANEPALS_JQ:-jq}"
python_bin="${PANEPALS_PYTHON:-python3}"
flake_file="${PANEPALS_FLAKE_FILE:-flake.nix}"
repo=i9wa4/tmux-a2a-postman
# During pre-rename staging, the PanePals candidate remains in the existing repo.
# An exact candidate commit must not be replaced by an older published tag.
if grep -Eq 'url = "github:i9wa4/tmux-a2a-postman/[0-9a-f]{40}";' "$flake_file"; then
  echo "input-update-panepals: exact candidate commit pinned; keeping it"
  exit 0
fi

if ! releases=$("$gh_bin" release list --repo "$repo" --limit 100 \
  --json tagName,isDraft,isPrerelease,publishedAt); then
  echo "input-update-panepals: failed to list releases for $repo" >&2
  exit 1
fi

if ! tag=$("$jq_bin" -r '
  [ .[]
    | select(.isDraft == false and .isPrerelease == false)
    | select(.publishedAt != null)
    | select(.tagName | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))
  ] | sort_by(.publishedAt) | last | .tagName // ""
' <<<"$releases"); then
  echo "input-update-panepals: invalid release data for $repo" >&2
  exit 1
fi
if [[ -z $tag ]]; then
  echo "input-update-panepals: no published stable release tag found for $repo" >&2
  exit 1
fi

"$python_bin" - "$flake_file" "$tag" <<'PY'
import os
import pathlib
import re
import sys
import tempfile

path = pathlib.Path(sys.argv[1])
tag = sys.argv[2]
text = path.read_text()
pattern = re.compile(
    r'(?m)^(\s*url = "github:i9wa4/tmux-a2a-postman/)([^"\n]+)(";)$'
)
matches = list(pattern.finditer(text))
if len(matches) != 1:
    raise SystemExit(
        f"input-update-panepals: expected one PanePals input URL in {path}, "
        f"found {len(matches)}"
    )
current = matches[0].group(2)
if current == tag:
    print(f"PanePals input already at {tag}")
    raise SystemExit(0)

updated = pattern.sub(lambda match: f"{match.group(1)}{tag}{match.group(3)}", text)
with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as output:
    temp_path = pathlib.Path(output.name)
    output.write(updated)
try:
    os.chmod(temp_path, path.stat().st_mode & 0o777)
    os.replace(temp_path, path)
finally:
    temp_path.unlink(missing_ok=True)
print(f"Updated PanePals input from {current} to {tag}")
PY
