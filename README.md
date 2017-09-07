## DESCRIPTION

## DOCKER BUILD

 `RELEASE_PACKAGE=##`  - Bamboo release package number
 
 `BUILD=##` - Bamboo build number

 `RELEASE_BUILD=#.#.#` - NuoDB's release number

 `VERSION=nuodb or nuodb-ce` - Community Edition or Full version of NuoDB

example:
```shell
# build on centos7
$ make

# OR

# build on rhel7
$ make TARGET=rhel7
```

further customizing the build w/ docker:
```bash
docker build \
    -t nuodb-2.6.1:latest \
    --build-arg RELEASE_PACKAGE=35 \
    --build-arg BUILD=8 \
    --build-arg BUILD_RELEASE=2.6.1 \
    --build-arg VERSION=nuodb-ce \
    --build-arg RHUSER=redhatAccount@example.com \
    --build-arg RHPASS=RedHatPassword
```
##DOCKER RUN

General environment variables:

    ENV_TYPE - Describes the ecosystem you're deploying the docker container in. 
                 The options are:
                     OPENSHIFT 
                     AWSEC2
                     AWSECS
                     AZURE
                     GOOGLE
                     
    AGENT_PORT="48011"
    NODE_PORT="48010"
    BROKER_PORT="48004"
    NODE_TYPE
    
OpenShift specific environment variables 

    OC_ADDRESS  - IP or FQDN of master OpenShift node 
    USERNAME    - OpenShift user account to execute oc commands
    PASSWORD    - OpenShift user's password


example: OpenShift
```bash
oc new-app docker.io/nuodbopenshift/nuodb-ce:latest \
    --name nuodb-deployer \
    -e "ENV_TYPE=OPENSHIFT" \
    -e "OC_ADDRESS=172.31.17.249"  \
    -e "USERNAME=developer"  \
    -e "PASSWORD=developer" 
```

## Adding new docker builds

The build process uses the properties files in build-params directory.
Each properties file generate a docker image that is built and pushed
to the appropriate repository ([docker
hub](https://hub.docker.com/r/nuodb/nuodb-ce) for NuoDB CE, internal
proprietary location for NuoDB full)

The properties file should look something like this:

```
RELEASE_BUILD=3.0.0
BUILD=4
PACKAGE_DIR=Linux-.tar.gz
RELEASE_PACKAGE=36
VERSION=nuodb
```

All of the above properties are used in constructing the path to
locate the appropriate artifact in the NuoDB build system.
Additionally, the `VERSION` property is used to distinguish between
NuoDB Full and NuoDB CE.

To add a new build, simply create another properties file with the
appropriate values.

## Docker tags

Each time an image is built, it is pushed to the apporpriate
repository with multiple tags.  This makes it possible to specify the
desired image to any level.

For example, when a NuoDB CE image is built of version 3.0.0, package 36, build 4, it is tagged as:

* nuodb/nuodb-ce:3.0.0
* nuodb/nuodb-ce:3.0.0-36
* nuodb/nuodb-ce:3.0.0-36-4
* nuodb/nuodb-ce:3.0.0-36-4-<build number> where the build number is the unique build on the NuoDB build system.

Note that the tag 'latest' is never used -- you must at least specify
the first component (version number) of the tag.


