FROM ubuntu:22.04
ENV TERM=xterm \
    TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/"${TZ}" /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && apt-get update \
    && apt-get install -y \
        git \
        vim
