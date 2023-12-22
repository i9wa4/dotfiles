#!/usr/bin/env bash
set -euxo pipefail

sudo apt update
sudo apt install -y make

make minimal
