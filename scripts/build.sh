#!/usr/bin/env bash

set -e

CWD=`pwd`

BUILD_DIR=${1:-build}
VERSION=${2:-5.17.2}
ROCKSDB_SOURCE_PATH=${3:-../rocksdb2}

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)     ext=dylib;;
    Linux*)      ext=so;;
    *)           echo "UNKNOWN OS : ${unameOut}"; exit 1
esac

LIB=librocksdb_plugins
OUT=${BUILD_DIR}/${LIB}.${ext}
JAVA_OUT=java/src/main/resources/${LIB}.${ext}

rm -f ${JAVA_OUT}

# copy some rocksdb sources to not depend on rocksdb binaries
cp ${ROCKSDB_SOURCE_PATH}/util/slice.cc src/.

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
if hash scl 2>/dev/null; then
    scl enable devtoolset-7 'cmake .. -DROCKSDBLIBJNI_PATH=${ROCKSDB_BIN} -DROCKSDB_PATH=${ROCKSDB_PATH}'
    scl enable devtoolset-7 'make rocksdb_plugins'
else
    cmake .. -DROCKSDBLIBJNI_PATH=${ROCKSDB_BIN} -DROCKSDB_PATH=${ROCKSDB_SOURCE_PATH}
	make rocksdb_plugins
fi
cd ${CWD}

cp ${OUT} ${JAVA_OUT}

cd java
mvn clean install
cd ${CWD}