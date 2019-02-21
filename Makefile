
ROCKSDB_VERSION ?= 5.17.2

.PHONY: $(MAKECMDGOALS)

# Crossbuild:

all: clean build-linux32 build-linux64 build-osx

prepare-rocksdb:
	git clone https://github.com/facebook/rocksdb
	cd rocksdb; git checkout v${ROCKSDB_VERSION}

clean:
	# docker rm -f rocksdb_linux_x86-be || true
	# docker rm -f rocksdb_linux_x64-be || true
	rm -rf build-*

build-linux32:
	./scripts/build-linux-docker.sh 32

build-linux64:
	./scripts/build-linux-docker.sh 64

build-osx:
	./scripts/build.sh osx

# Only for windows:

win-prepare: prepare-rocksdb
	choco install jdk8 maven visualstudio2017community intellijidea-community vscode

build-win:
	.\scripts\build-win.bat