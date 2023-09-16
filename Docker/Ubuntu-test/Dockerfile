FROM ubuntu:22.04
ENV TERM=xterm \
    TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y vim git \
    && vim /etc/apt/sources.list -c "%s/# deb-src/deb-src" -c "wq" \
    && apt-get update \
    && apt-get build-dep -y python3 \
    && apt-get install -y build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev
WORKDIR /usr/local/src/
RUN git clone https://github.com/python/cpython -b v3.11.1
WORKDIR /usr/local/src/cpython/
RUN ./configure \
    && make \
    && make altinstall

