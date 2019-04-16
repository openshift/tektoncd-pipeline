# Do not edit! This file was generated via Makefile
FROM registry.access.redhat.com/ubi8-dev-preview/ubi:latest

RUN yum install -y git openssh-client

ADD git-init /ko-app/git-init
ENTRYPOINT ["/ko-app/git-init"]
