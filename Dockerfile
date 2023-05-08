FROM ubuntu:jammy

USER 0

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive

ARG CPUARCH
ENV CPUARCH amd64 
ARG CPUARCH_EXT 
ENV CPUARCH_EXT x86_64

ARG OS 
ENV OS linux
ARG OS_EXT 
ENV OS_EXT Linux

RUN apt-get update && \
    apt-get -y install \
      curl \
      netcat \
      gnupg \
      software-properties-common \
      lsb-core \
      jq \
      python3-ncclient \
      python3-pip \
      python-is-python3 \
      ssh \
      vim \
      git \
      mysql-client \
      postgresql-client \ 
      unzip \
      && \
    useradd -m -d /home/cloud -s /bin/bash -u 1000 cloud && \
    rm -rf /var/lib/apt/lists/* && \ 
    pip3 install --no-cache-dir \
      boto \
      botocore \
      boto3 \
      awscli \
      azure-cli \
      ansible \
      openshift \
      kubernetes
    
# Go stuff
ARG GO_VERSION 
ENV GO_VERSION=${GO_VERSION:-1.20.4}
RUN set -ex; \  
    curl -fsSLo go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${CPUARCH}.tar.gz" && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz 
ENV PATH=${PATH}:/usr/local/go/bin

# terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION:-1.4.6}
RUN set -ex && \
    curl -fsSLo terraform.zip "https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${OS}_${CPUARCH}.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin && \
    rm terraform.zip && \
    chmod +x /usr/local/bin/terraform

# helm: https://helm.sh/docs/intro/install/
# https://get.helm.sh/helm-v3.12.0-rc.1-linux-amd64.tar.gz
ARG HELM_VERSION
ENV HELM_VERSION=${HELM_VERSION:-3.11.3}
RUN set -ex; \
    curl -fsSLo helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${CPUARCH}.tar.gz" && \
    tar xfvz helm.tar.gz && \
    cp ${OS}-${CPUARCH}/helm /usr/local/bin/helm && \
    rm -rf helm.tar.gz ${OS}-${CPUARCH} && \
    chmod +x /usr/local/bin/helm 

# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# version: https://dl.k8s.io/release/stable.txt
ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION:-1.27.1}
RUN set -xe && \
    curl -fsSLo kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${OS}/${CPUARCH}/kubectl" && \
    mv kubectl /usr/local/bin  && \
    chmod +x /usr/local/bin/kubectl
    

USER 1000
WORKDIR /home/cloud
RUN /usr/local/bin/ansible-galaxy collection install community.kubernetes
