FROM ubuntu:jammy

RUN apt-get update && \
    apt-get -y install \
        unzip \
        curl \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        software-properties-common \
        sqlite3 \
        strace \
        tree \
        gcc \
        python3 \
        python3-pip \
        python3-virtualenv \
        gettext \
        jq \
        wget \
        netcat \
        ssh \
    && apt-get clean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --ignore-installed -U \
        awscli \
        ansible \
        botocore \
        boto \
        boto3 \
        openshift==0.12.1 \
        kubernetes==12.0.1 \
        PyYAML \
    && rm -rf "${HOME}"/.cache


