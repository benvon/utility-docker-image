# utility-docker-image
Docker image with a bunch of useful tools installed based on Ubuntu Noble. This image is intended to be used as a base for kubernetes automation or "service-pod" type use-cases where it may be useful for troubleshooting and diagnostics.

[![Quality Gate Status](https://sonarqube.benvon.net/api/project_badges/measure?project=benvon_utility-docker-image_8b1dba07-aef3-4051-9fe2-485cb5a20ae4&metric=alert_status&token=sqb_ad2e158bb6f6c37a2fd1676eabefa45b64fcee6d)](https://sonarqube.benvon.net/dashboard?id=benvon_utility-docker-image_8b1dba07-aef3-4051-9fe2-485cb5a20ae4)

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
