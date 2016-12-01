#!/bin/sh

cd "${BASH_SOURCE%/*}"
echo "Building Protobuf"
cd build-protobuf/
./build-protobuf.sh

cd ..
echo "Building Mosh"
./build-mosh.sh
./create-libmoshios-framework.sh

