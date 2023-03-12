#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

# sudo apt update
sudo apt install -y --no-install-recommends \
  software-properties-common dirmngr
wget -qO- \
  https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository -y \
  "deb https://cloud.r-project.org/bin/linux/ubuntu \
  $(lsb_release -cs)-cran40/"
sudo apt install -y --no-install-recommends r-base
sudo apt install -y pandoc
sudo R -e "install.packages('rmarkdown')"
sudo R -e "install.packages('IRkernel')"
# $ activate venv
# $ R
# $ IRkernel::installspec()

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
