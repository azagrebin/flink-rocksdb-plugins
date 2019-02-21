#!/usr/bin/env bash

set -e

CWD=`pwd`

LIBSUFFIX=${1:-osx}
BUILD_DIR=${2:-build-${LIBSUFFIX}}
ROCKSDB_SOURCE_PATH=${3:-rocksdb}
LIBNAME=${4:-frocksdbplugins}

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)     ext=dylib;;
    Linux*)      ext=so;;
    *)           echo "UNKNOWN OS : ${unameOut}"; exit 1
esac

LIBFULLNAME=${LIBNAME}jni-${LIBSUFFIX}
LIB=lib${LIBFULLNAME}
OUT=${BUILD_DIR}/${LIB}.${ext}
JAVA_OUT=java/src/main/resources/${LIB}.${ext}

rm -f ${JAVA_OUT}
cd java
mvn clean compile # generate jni headers
cd ${CWD}

# copy some rocksdb sources to not depend on rocksdb binaries
cp ${ROCKSDB_SOURCE_PATH}/util/slice.cc src/.
cp ${ROCKSDB_SOURCE_PATH}/db/merge_operator.cc src/.

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
cmake .. -DROCKSDB_SOURCE_PATH=${ROCKSDB_SOURCE_PATH} -DLIBNAME=${LIBFULLNAME}
make check
make ${LIBFULLNAME}
cd ${CWD}

cp ${OUT} ${JAVA_OUT}

cd java
mvn clean install
cd ${CWD}

echo "Result is in:"
echo "${JAVA_OUT}"