FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/benvon/utility-docker-image/
LABEL org.opencontainers.image.base.name=ubuntu
LABEL org.opencontainers.image.base.version=24.04
LABEL org.opencontainers.maintainer="Ben Vaughan <ben@benvon.net>"

USER 0

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ARG CPUARCH
ENV CPUARCH=amd64 
ARG CPUARCH_EXT 
ENV CPUARCH_EXT=x86_64

ARG OS 
ENV OS=linux
ARG OS_EXT 
ENV OS_EXT=Linux

ARG TESTSSLVERSION=3.0.9


RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -yq --no-install-recommends install \
        bsdmainutils \
        curl \
        dnsutils \
        git \
        gnupg \
        lsb-release \
        mysql-client \
        net-tools \
        netcat-openbsd \
        postgresql-client \
        software-properties-common \
        ssh \
        unzip \
        vim \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# shortcut to install azcli
RUN	curl --proto "=https" --tlsv1.2 -sL https://aka.ms/InstallAzureCLIDeb | bash

# set up a user inside the container
RUN useradd -m -d /home/cloud -s /bin/bash -u 5000 cloud
USER cloud
ENV PATH="${PATH}:/home/cloud/.asdf/shims:/home/cloud/.asdf/bin:/home/cloud/bin"
WORKDIR /home/cloud

COPY --chown=cloud:cloud .tool-versions /home/cloud/.tool-versions

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git "$HOME/.asdf" && \
    echo '. "$HOME/.asdf/asdf.sh"' >> "$HOME"/.bashrc && \
    echo '. "$HOME/.asdf/asdf.sh"' >> "$HOME"/.profile && \
    awk -F'[ #]' '$NF ~ /https/ {system("asdf plugin add " $1 " " $NF)} $1 ~ /./ {system("asdf plugin add " $1 "; asdf install " $1 " " $2)}' ./.tool-versions && \
    chown -R cloud:cloud "$HOME" && \
    mkdir -p "$HOME"/bin

# testssl: https://github.com/drwetter/testssl.sh/pkgs/container/testssl.sh#installation
ADD --chown=cloud:cloud https://codeload.github.com/drwetter/testssl.sh/tar.gz/v${TESTSSLVERSION} testssl.tar.gz
RUN tar -xvf testssl.tar.gz && \
    mv testssl.sh-${TESTSSLVERSION} bin/testssl && \
    chmod +x bin/testssl && \
    rm -rf testssl.tar.gz

ENV PATH="${PATH}:/home/cloud/.asdf/shims:/home/cloud/.asdf/bin:/home/cloud/bin:/home/cloud/bin/testssl"
