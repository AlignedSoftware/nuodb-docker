
FROM centos

ARG RELEASE_PACKAGE=35
ARG BUILD=8
ARG RELEASE_BUILD=2.6.1
ARG VERSION=nuodb

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

RUN yum install java network-manager git -y

RUN curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/Linux-.tar.gz/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar -xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
    && rm -rf /tmp/nuodb.tgz \
    && git clone https://github.com/thebithead/nuoca.git /opt/nuoca

#remove extra directories
RUN rm -rf /opt/nuodb/samples && rm -rf /opt/nuodb/doc && rm -rf /opt/nuodb/tools

ADD scripts /scripts
COPY help.1 /

#set ownership of nuodb home and execute on scripts
CMD chown -R root:root /opt/nuodb && chmod -R +x /scripts

ENTRYPOINT ["/scripts/entrypoint.sh"]
