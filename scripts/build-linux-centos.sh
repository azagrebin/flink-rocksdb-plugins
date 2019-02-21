#!/usr/bin/env bash

set -e

ARCH=${1-64}
DIR_NAME=${2:-flink-rocksdb-plugins}

TOOLSET=7
if [ "${ARCH}" = "32" ]; then
    ARCHPRE=linux32
    TOOLSET=2
fi

${ARCHPRE} yum -y remove java-1.7.0-openjdk-devel
${ARCHPRE} yum -y install java-1.8.0-openjdk-devel

if [ ! -d "maven" ]; then
    wget http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
    tar xzf apache-maven-3.5.4-bin.tar.gz
    ln -s apache-maven-3.5.4 maven
fi

export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export M2_HOME=/maven
export PATH=${M2_HOME}/bin:${PATH}

cd /host/${DIR_NAME}

if hash scl 2>/dev/null; then
    source /opt/rh/devtoolset-${TOOLSET}/enable
fi
${ARCHPRE} scripts/build.sh linux${ARCH}