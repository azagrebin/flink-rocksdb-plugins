
## Build in PPC64LE

 Use Ubuntu 16.04 (e.g. AWS instance 4 cores, 16GB RAM, 40GB storage for build).
 Install git if not installed. If docker is installed, it might need to be removed.

 Setup ppc64le docker machine ([source](https://developer.ibm.com/linuxonpower/2017/06/08/build-test-ppc64le-docker-images-intel/)):

     wget http://ftp.unicamp.br/pub/ppc64el/boot2docker/install.sh && chmod +x ./install.sh && ./install.sh -s
     docker-machine create -d qemu \
         --qemu-boot2docker-url=/home/ubuntu/.docker/machine/boot2docker.iso \
         --qemu-memory 8192 \
         --qemu-cache-mode none \
         --qemu-arch ppc64le \
         vm-ppc64le

 Regenerate certs as suggested if it did not work at once.

 Prepare docker machine to run rocksdbjni docker image for ppc64le build:

     eval $(docker-machine env vm-ppc64le)
     git clone https://github.com/azagrebin/flink-rocksdb-plugins
     cd flink-rocksdb-plugins
     git checkout <release tag>
     docker-machine ssh vm-ppc64le mkdir -p `pwd`
     docker-machine scp -r . vm-ppc64le:`pwd`

### Build in Windows

Use Windows 64 bit machine (e.g. base AWS Windows instance: 4 cores, 16GB RAM, 40GB storage for build).

Open cmd, install [chocolatey](https://chocolatey.org/install) and run:

    choco install make git.install
    git clone https://github.com/azagrebin/flink-rocksdb-plugins
    cd flink-rocksdb-plugins
    git checkout <release tag>
    ROCKSDB_VERSION=5.17.2 make win-prepare &:: install useful software and clone rocksdb, might take time
    make build-win
    
### Cross-platform build in Mac OSX

Clone rocksdb:

    ROCKSDB_VERSION=5.17.2 make prepare-rocksdb

Install docker and run:

    cp <windows library location>/liblibfrocksdbpluginsjni-linux.dll java/src/main/resources/.
    cp <ppc64le library location>/liblibfrocksdbpluginsjni-linux-ppc64le.so java/src/main/resources/.
    make