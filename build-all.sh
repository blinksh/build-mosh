#!/bin/sh

echo "Building Protobuf"
./build-protobuf/build-protobuf.sh
echo "Building Mosh"
./build-mosh.sh
./create-libmoshios-framework.sh