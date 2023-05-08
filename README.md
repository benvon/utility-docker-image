# utility-docker-image
Docker image with a bunch of useful tools installed based on Ubuntu Jammy. This image is intended to be used as a base for kubernetes automation or "service-pod" type use-cases where it may be useful for troubleshooting and diagnostics.

## Ubuntu maintained packages

- curl 
- netcat 
- gnupg 
- software-properties-common 
- lsb-core 
- jq 
- python3-ncclient 
- python3-pip 
- python-is-python3 
- ssh 
- vim 
- git 
- mysql-client 
- postgresql-client  
- unzip 

## PIP packages 

 - boto 
 - botocore 
 - boto3 
 - awscli 
 - azure-cli 
 - ansible 
 - openshift 
 - kubernetes

## Image maintainer packages:

- Helm - 3.11.3
- Kubectl - 1.27.1
- Terraform - 1.4.6
- Go - 1.20.4
