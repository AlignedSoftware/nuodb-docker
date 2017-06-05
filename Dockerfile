
FROM registry.access.redhat.com/rhel7

ARG RELEASE_PACKAGE=35
ARG BUILD=8
ARG RELEASE_BUILD=2.6.1
ARG VERSION=nuodb-ce
ARG RHUSER
ARG RHPASS

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

ADD install /tmp

RUN subscription-manager register --username=$RHUSER --password=$RHPASS \
    && subscription-manager attach --pool=8a85f9815b58a400015b58e392315383 \
    && subscription-manager repos --disable="*" \
    && subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.0-rpms"

RUN yum install net-tools java unzip -y && subscription-manager unregister
#RUN curl -SL http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jre-8u131-linux-x64.rpm -o /tmp/jre-8u131-linux-x64.rpm

RUN tar xvf /tmp/oc-3.5.5.8-linux.tar.gz -C /bin && rm /tmp/oc-3.5.5.8-linux.tar.gz \
    && curl -SL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/awscli-bundle.zip \
    && unzip /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -rf /tmp/awscli*

RUN curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/Linux-.tar.gz/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
    && rm -rf /tmp/nuodb.tgz

ADD scripts /scripts
COPY help.1 /

CMD ["bash", "/scripts/entrypoint.sh"]
