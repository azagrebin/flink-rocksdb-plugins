#!/usr/bin/env bash

set -e

BUILD_DIR=${1:-build}
VERSION=${2:-5.17.2}
ROCKSDB_BIN=${3:-rocksdbjni-bin}
ROCKSDB_PATH=${4:-../rocksdb2}

#rm -rf ${ROCKSDB_BIN}
scripts/get_rocksdb_dependency.sh ${VERSION} ${ROCKSDB_BIN}

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
if hash scl 2>/dev/null; then
    scl enable devtoolset-7 'cmake .. -DROCKSDBLIBJNI_PATH=${ROCKSDB_BIN} -DROCKSDB_PATH=${ROCKSDB_PATH}'
    scl enable devtoolset-7 'make rocksdb_plugins'
else
    cmake .. -DROCKSDBLIBJNI_PATH=${ROCKSDB_BIN} -DROCKSDB_PATH=${ROCKSDB_PATH}
	make rocksdb_plugins
fi
cd ..

LIB=${BUILD_DIR}/librocksdb_plugins
unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)     ext=dylib;;
    Linux*)      ext=so; patchelf --set-rpath '$ORIGIN' ${LIB}.${ext};;
    *)           echo "UNKNOWN OS : ${unameOut}"; exit 1
esac
cp ${LIB}.${ext} java/src/main/resources/.