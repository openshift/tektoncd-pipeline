# Do not edit! This file was generated via Makefile
FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base

RUN yum install -y git openssh-client

ADD git-init /ko-app/git-init
ENTRYPOINT ["/ko-app/git-init"]
