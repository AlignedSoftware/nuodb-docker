FROM centos

ARG RELEASE_PACKAGE=35
ARG BUILD=5
ARG RELEASE_BUILD=2.6.1
ARG VERSION=nuodb

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

RUN yum install  --setopt=tsflags=nodocs java net-tools git -y

RUN curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/Linux-.tar.gz/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar -xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
    && rm -rf /tmp/nuodb.tgz \
    && git clone https://github.com/thebithead/nuoca.git /opt/nuoca

#set ownership of nuodb home
RUN chown -R root:root /opt/nuodb

#remove extra directories
RUN rm -rf /opt/nuodb/samples && rm -rf /opt/nuodb/doc && rm -rf /opt/nuodb/tools

ADD scripts /scripts
COPY help.1 /

#USER 99

ENTRYPOINT ["/scripts/entrypoint.sh"]
