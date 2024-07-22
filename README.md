# utility-docker-image
Docker image with a bunch of useful tools installed based on Ubuntu Noble. This image is intended to be used as a base for kubernetes automation or "service-pod" type use-cases where it may be useful for troubleshooting and diagnostics.

## Ubuntu maintained packages

- curl 
- netcat 
- gnupg 
- software-properties-common 
- lsb-release
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

## Image maintainer packages:

- Helm - 3.15.0
- Kubectl - 1.29.5
- Terraform - 1.5.5
- Go - 1.22.5
