
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# NOTE(chmou): *BEWARE YOU ARE ENTERING IN A WORLD OF UGLY HACK#.
# Sidecar is currently broken with a nop image that's not based on google's
# distroless. We want to mimic as much as possible the distroless image but
# still be based on a UBI, it's not pretty but let's hope we can remove this when
# we get https://github.com/tektoncd/pipeline/issues/1347
RUN for i in /usr/bin/* /usr/sbin/* /bin/* /sbin/*;do \
    [[ $i == *bin/rm || $i == *bin/coreutils ]] && continue;rm -vf $i;done

ADD nop /ko-app/nop
ENTRYPOINT ["/ko-app/nop"]
