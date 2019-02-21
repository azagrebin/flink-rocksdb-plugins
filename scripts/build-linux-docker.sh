#!/usr/bin/env bash

ARCH=${1:-64}
DIR_NAME=${PWD##*/}

XXX=86
if [ "${ARCH}" = "64" ]; then
    XXX=64
fi

CONTAINER_NAME=rocksdb_linux_x${XXX}-be

mkdir -p java/target

DOCKER_LINUX_CONTAINER=`docker ps -aqf name=rocksdb_linux_x${ARCH}-be`
if [ -z "${DOCKER_LINUX_CONTAINER}" ]; then
	docker container create \
		--attach stdin --attach stdout --attach stderr \
		--volume `pwd`/..:/host \
		--name ${CONTAINER_NAME} evolvedbinary/rocksjava:centos6_x${XXX}-be \
		/host/${DIR_NAME}/scripts/build-linux-centos.sh ${ARCH} ${DIR_NAME};
fi

docker start -a ${CONTAINER_NAME}