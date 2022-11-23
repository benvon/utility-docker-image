FROM ubuntu:focal

USER 0
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
      curl \
      netcat \
      gnupg \
      software-properties-common \
      lsb-core \
      && \
    echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 93C4A3FD7BB9C367 && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
       jq \
       python3-ncclient \
       python3-pip \
       ssh \
       vim \
       git \
       terraform \
       kubectl \
       helm \
       mysql-client \
       postgresql-client \ 
       && \
     useradd -m -d /home/cloud -s /bin/bash -u 1000 cloud && \
     rm -rf /var/lib/apt/lists/* && \ 
     pip3 install \
       boto \
       botocore \
       boto3 \
       awscli \
       ansible \
       openshift==0.12.1 \
       kubernetes==12.0.1 
    

USER 1000
WORKDIR /home/cloud
RUN /usr/local/bin/ansible-galaxy collection install community.kubernetes
