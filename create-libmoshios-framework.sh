#!/bin/sh

FWNAME=libmoshios

if [ ! -d output ]; then
    echo "Please run build-libssh2.sh first!"
    exit 1
fi

if [ -d $FWNAME.framework ]; then
    echo "Removing previous $FWNAME.framework copy"
    rm -rf $FWNAME.framework
fi


echo "Creating $FWNAME.framework"
mkdir -p $FWNAME.framework/Headers
cp output/libmoshios.a $FWNAME.framework/$FWNAME
cp -r mosh/src/frontend/moshiosbridge.h $FWNAME.framework/Headers/
echo "Created $FWNAME.framework"
