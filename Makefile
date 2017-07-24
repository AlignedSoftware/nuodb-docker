CONTEXT = nuodbopenshift
VERSION = 2.6.1
IMAGE_NAME = nuodb-ce
REGISTRY = docker-registry.default.svc.cluster.local

# Allow user to pass in OS build options
ifeq ($(TARGET),rhel7)
	DFILE := Dockerfile.${TARGET}
else
	TARGET := centos7
	DFILE := Dockerfile
endif

all: build
build:
	docker build --pull -t ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} -t ${CONTEXT}/${IMAGE_NAME} -f ${DFILE} .
	@if docker images ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}; then touch build; fi

lint:
	dockerfile_lint -f Dockerfile
	dockerfile_lint -f Dockerfile.rhel7

test:
	$(eval CONTAINERID=$(shell docker run -tdi ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}))
	@sleep 5
	@docker exec ${CONTAINERID} ps aux
	@docker logs ${CONTAINERID}
	@docker rm -f ${CONTAINERID}

#run:
#	docker run -tdi -u `shuf -i 1000010000-1000020000 -n 1` ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}

clean:
	rm -f build