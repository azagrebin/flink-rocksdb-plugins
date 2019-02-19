#!/usr/bin/env bash

set -e

wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum -y install apache-maven
yum -y install patchelf

cd /rocksdb-host/rocksdb_plugins

scripts/build.sh docker-build-linux64

rm -rf docker-build-linux64