FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/benvon/utility-docker-image/
LABEL org.opencontainers.image.base.name=ubuntu

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



RUN apt-get update && \
    apt-get -y install \
      curl \
      netcat-openbsd \
      gnupg \
      software-properties-common \
    #   lsb-core \
      lsb-release \
      jq \
      python3-ncclient \
      python3-pip \
      python-is-python3 \
      python3-botocore \
      python3-boto3 \
      python3-boto \
      python3-openshift \
      python3-kubernetes \
      ansible \
      ssh \
      vim \
      git \
      mysql-client \
      postgresql-client \ 
      unzip \
      net-tools 


    
# Go stuff
ARG GO_VERSION 
ENV GO_VERSION=${GO_VERSION:-1.22.5}
RUN set -ex; \  
    curl -fsSLo go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${CPUARCH}.tar.gz" && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz 
ENV PATH=${PATH}:/usr/local/go/bin

# terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION:-1.5.5}
RUN set -ex && \
    curl -fsSLo terraform.zip "https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${OS}_${CPUARCH}.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin && \
    rm terraform.zip && \
    chmod +x /usr/local/bin/terraform

# helm: https://helm.sh/docs/intro/install/
# https://get.helm.sh/helm-v3.12.0-rc.1-linux-amd64.tar.gz
ARG HELM_VERSION
ENV HELM_VERSION=${HELM_VERSION:-3.15.0}
RUN set -ex; \
    curl -fsSLo helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${CPUARCH}.tar.gz" && \
    tar xfvz helm.tar.gz && \
    cp ${OS}-${CPUARCH}/helm /usr/local/bin/helm && \
    rm -rf helm.tar.gz ${OS}-${CPUARCH} && \
    chmod +x /usr/local/bin/helm 

# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# version: https://dl.k8s.io/release/stable.txt
ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION:-1.29.5}
RUN set -xe && \
    curl -fsSLo kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${OS}/${CPUARCH}/kubectl" && \
    mv kubectl /usr/local/bin  && \
    chmod +x /usr/local/bin/kubectl
    
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    /usr/local/bin/aws --version && \
    rm -rf awscliv2.zip aws

# shortcut to install azcli
RUN	curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN useradd -m -d /home/cloud -s /bin/bash -u 5000 cloud
USER cloud
WORKDIR /home/cloud
RUN ansible-galaxy collection install community.kubernetes
