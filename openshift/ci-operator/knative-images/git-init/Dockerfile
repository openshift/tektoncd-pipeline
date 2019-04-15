# Do not edit! This file was generated via Makefile
FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base

ENV APP_ROOT=/opt/app-root

# NOTE(chmou): We use $ here so that envsubst don't get confused and expand
# our local PATH.
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
RUN yum install -y git openssh-client

COPY git-init /ko-app/git-init.orig
COPY uidwrapper /ko-app/git-init

RUN chmod -R u+x /bin && \
    chgrp -R 0  && \
    chmod -R g=u  /etc/passwd

ENTRYPOINT ["/ko-app/git-init"]

# Local Variables:
# mode: dockerfile
# End:
