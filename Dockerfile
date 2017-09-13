FROM docker.io/centos:7

ARG RELEASE_PACKAGE=36
ARG BUILD=4
ARG RELEASE_BUILD=3.0.0
ARG VERSION=nuodb
ARG PACKAGE_DIR=Linux-CE

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

ADD install /tmp

RUN yum -y install epel-release
RUN yum -y install --setopt=tsflags=nodocs java net-tools git python-pip \
    && curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/$PACKAGE_DIR/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar -xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
    && tar -xvf /tmp/oc-3.5.5.8-linux.tar.gz -C /bin && rm /tmp/oc-3.5.5.8-linux.tar.gz \
#remove extra directories
    && rm -rf /opt/nuodb/{samples,doc} \
    && rm -rf /tmp/nuodb.tgz \
    && git clone https://github.com/thebithead/nuoca.git /opt/nuoca \
    && git clone https://github.com/thebithead/nuomonitor.git /opt/nuomonitor \
    && yum autoremove git -y \
    && yum clean all

RUN /usr/bin/pip install -r /opt/nuoca/requirements.txt

ADD scripts /scripts
ADD dbSchema /dbSchema
COPY help.1 /
COPY LICENSE /licenses/

RUN useradd -l -u 1000 -r -g 0 -d /opt/nuodb -s /sbin/nologin -c "nuodb user" nuodb \
#set ownership of nuodb home
    && chown -R nuodb:0 /opt/{nuodb,nuoca} /scripts \
    && chmod -R g=u /opt/{nuodb,nuoca} /scripts

USER 1000

ENTRYPOINT ["/scripts/entrypoint.sh"]
