# utility-docker-image
Docker image with a bunch of useful tools installed based on Ubuntu Noble. This image is intended to be used as a base for kubernetes automation or "service-pod" type use-cases where it may be useful for troubleshooting and diagnostics.

## Ubuntu maintained packages

- curl 
- netcat 
- gnupg 
- software-properties-common 
- lsb-release
- ssh 
- vim 
- git 
- mysql-client 
- postgresql-client  
- unzip 

## Tool manager

Runtime tools are installed and version-pinned via [`mise`](./.tool-versions).

Current managed tools:

- awscli
- golang
- golangci-lint
- helm
- jq
- kubectl
- pre-commit
- python
- terraform
- terragrunt

## CI gates

- `Container Tests`: image build + container-structure tests for tool availability and runtime behavior.
- `Security Gate`: GitHub dependency review + CodeQL analysis.

These two workflows are intended to be configured as required checks for `main`.

## Release flow

- Pushes and scheduled runs build/publish to `ghcr.io` and sign images with `cosign`.
- Semver tags (`v*.*.*`) publish both the container image and a GitHub Release.

## Supply chain hardening

- GitHub Actions are pinned to immutable commit SHAs.
- The base image is pinned to an immutable digest.
- External artifacts (`testssl` tarball and apt signing keys) are checksum-verified during build.
