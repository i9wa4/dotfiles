#!/usr/bin/env bash
set -o verbose
set -o xtrace
set -o errexit
set -o nounset
set -o pipefail
set -o posix

cd $HOME
cd "$(dirname "$0")"

echo "Hello, World!"
sleep 1
echo "Done."
