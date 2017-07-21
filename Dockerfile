FROM docker.io/centos:7

ARG RELEASE_PACKAGE=35
ARG BUILD=8
ARG RELEASE_BUILD=2.6.1
ARG VERSION=nuodb

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

RUN yum -y install --setopt=tsflags=nodocs java net-tools git \
    && curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/Linux-.tar.gz/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar -xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
#remove extra directories
    && rm -rf /opt/nuodb/{samples,doc,tools} \
    && rm -rf /tmp/nuodb.tgz \
    && git clone https://github.com/thebithead/nuoca.git /opt/nuoca \
    && yum autoremove git -y \
    && yum clean all

ADD scripts /scripts
COPY help.1 /
COPY LICENSE /licenses/

RUN useradd -l -u 1000 -r -g 0 -d /opt/nuodb -s /sbin/nologin -c "nuodb user" nuodb \
#set ownership of nuodb home
    && chown -R nuodb:0 /opt/{nuodb,nuoca} /scripts \
    && chmod -R g=u /opt/{nuodb,nuoca} /scripts

USER 1000

ENTRYPOINT ["/scripts/entrypoint.sh"]
