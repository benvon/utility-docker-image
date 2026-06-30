# syntax=docker/dockerfile:1.7

FROM ubuntu:noble@sha256:786a8b558f7be160c6c8c4a54f9a57274f3b4fb1491cf65146521ae77ff1dc54

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
ARG TESTSSL_SHA256=75ecbe4470e74f9ad17f4c4ac733be123b0f67d676ed24cc2b30adb41561e05f
ARG MISE_GPG_PUB_SHA256=91c72340c5cc84ae2ba98c1070083feacf789b0a4a3d34b2416147769e475d96
ARG MICROSOFT_ASC_SHA256=2fa9c05d591a1582a9aba276272478c262e95ad00acf60eaee1644d93941e3c6


RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -yq --no-install-recommends install \
        ca-certificates \
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
    install -dm 755 /etc/apt/keyrings && \
    curl -fsSL -o /tmp/mise-archive-keyring.asc https://mise.jdx.dev/gpg-key.pub && \
    echo "${MISE_GPG_PUB_SHA256}  /tmp/mise-archive-keyring.asc" | sha256sum -c - && \
    mv /tmp/mise-archive-keyring.asc /etc/apt/keyrings/mise-archive-keyring.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" > /etc/apt/sources.list.d/mise.list && \
    apt-get update && \
    apt-get -yq --no-install-recommends install \
        mise \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# install az cli from Microsoft apt repository without piping remote scripts
RUN set -eux; \
    install -dm 755 /etc/apt/keyrings; \
    curl -fsSL -o /tmp/microsoft.asc https://packages.microsoft.com/keys/microsoft.asc; \
    echo "${MICROSOFT_ASC_SHA256}  /tmp/microsoft.asc" | sha256sum -c -; \
    gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg /tmp/microsoft.asc; \
    rm -f /tmp/microsoft.asc; \
    chmod go+r /etc/apt/keyrings/microsoft.gpg; \
    AZ_REPO="$(lsb_release -cs)"; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ ${AZ_REPO} main" > /etc/apt/sources.list.d/azure-cli.list; \
    apt-get update; \
    apt-get -yq --no-install-recommends install azure-cli; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# set up a user inside the container
RUN useradd -m -d /home/cloud -s /bin/bash -u 5000 cloud
USER cloud
ENV MISE_DATA_DIR=/home/cloud/.local/share/mise
ENV MISE_CONFIG_DIR=/home/cloud/.config/mise
ENV MISE_CACHE_DIR=/home/cloud/.cache/mise
ENV PATH="${PATH}:/home/cloud/.local/share/mise/shims:/home/cloud/bin"
WORKDIR /home/cloud

COPY --chown=cloud:cloud .tool-versions /home/cloud/.tool-versions

RUN --mount=type=secret,id=github_token \
    set -eux; \
    mkdir -p "$HOME"/bin "$MISE_CONFIG_DIR" "$MISE_CACHE_DIR"; \
    if [[ -f /run/secrets/github_token ]]; then \
        export GITHUB_TOKEN="$(cat /run/secrets/github_token)"; \
    fi; \
    declare -A latest_version_for_tool=(); \
    declare -a tool_order=(); \
    while IFS= read -r line; do \
        clean_line="${line%%#*}"; \
        if [[ -z "${clean_line//[[:space:]]/}" ]]; then \
            continue; \
        fi; \
        read -r tool version _ <<< "${clean_line}"; \
        if [[ -z "${tool}" || -z "${version}" ]]; then \
            continue; \
        fi; \
        if [[ "${line}" =~ \#(https://[^[:space:]]+) ]]; then \
            mise plugins install "${tool}" "${BASH_REMATCH[1]}"; \
        fi; \
        mise install "${tool}@${version}"; \
        if [[ -z "${latest_version_for_tool[${tool}]+x}" ]]; then \
            tool_order+=("${tool}"); \
        fi; \
        latest_version_for_tool["${tool}"]="${version}"; \
    done < ./.tool-versions; \
    { \
        echo "[tools]"; \
        for tool in "${tool_order[@]}"; do \
            echo "${tool} = \"${latest_version_for_tool[${tool}]}\""; \
        done; \
    } > "${MISE_CONFIG_DIR}/config.toml"; \
    mise reshim

# testssl: https://github.com/drwetter/testssl.sh/pkgs/container/testssl.sh#installation
RUN curl -fsSL --retry 5 --retry-delay 2 -o testssl.tar.gz "https://codeload.github.com/drwetter/testssl.sh/tar.gz/v${TESTSSLVERSION}" && \
    echo "${TESTSSL_SHA256}  testssl.tar.gz" | sha256sum -c - && \
    tar -xvf testssl.tar.gz && \
    mv testssl.sh-${TESTSSLVERSION} bin/testssl && \
    chmod +x bin/testssl && \
    rm -rf testssl.tar.gz

ENV PATH="${PATH}:/home/cloud/.local/share/mise/shims:/home/cloud/bin:/home/cloud/bin/testssl"
