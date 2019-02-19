#!/usr/bin/env bash

set -e

VERSION=${1:-5.17.2}
TARGET=${2:-rocksdbjni-bin}

CDIR=`pwd`
JAR=rocksdbjni-${VERSION}.jar
MVNJAR=$HOME/.m2/repository/org/rocksdb/rocksdbjni/${VERSION}/${JAR}
OUTJAR="${TARGET}/${JAR}"

mkdir -p "${TARGET}"

if [ ! -f "${OUTJAR}" ]; then
    if [ -f "${MVNJAR}" ]; then
        cp "${MVNJAR}" "${TARGET}/.";
    else
        curl -o "${OUTJAR}" "http://central.maven.org/maven2/org/rocksdb/rocksdbjni/${VERSION}/${JAR}";
    fi

    cd "${TARGET}"; jar -xvf "${JAR}"; cd "${CDIR}"
    cp "${TARGET}/librocksdbjni-osx.jnilib" "${TARGET}/librocksdbjni-osx.dylib"
    rm -rf "${TARGET}/META-INF" "${TARGET}/org" "${TARGET}/org" "${TARGET}/HISTORY-JAVA.md"
fi