#!/bin/bash

pwd=`pwd`
PROTOBUFDIR="$pwd/protobuf-release"
XCODEPATH=`xcode-select --print-path`
PLATFORMPATH="$XCODEPATH/Platforms"
TOOLSPATH="$XCODEPATH/Toolchains/XcodeDefault.xctoolchain/usr/bin"

export IPHONEOS_DEPLOYMENT_TARGET="8.0"


findLatestSDKVersion()
{
    sdks=`ls $PLATFORMPATH/$1.platform/Developer/SDKs`
    arr=()
    for sdk in $sdks
    do
	arr[${#arr[@]}]=$sdk
    done

    # Last item will be the current SDK, since it is alpha ordered
    count=${#arr[@]}
    if [ $count -gt 0 ]; then
	sdk=${arr[$count-1]:${#1}}
	num=`expr ${#sdk}-4`
	SDKVERSION=${sdk:0:$num}
    else
	SDKVERSION="8.0"
    fi
}

buildit()
{
    target=$1
    hosttarget=$1
    platform=$2

    export ac_cv_path_PROTOC="$PROTOBUFDIR/bin/protoc"
    export protobuf_LIBS="$PROTOBUFDIR/lib/libprotobuf.a"
    export protobuf_CFLAGS="-I$PROTOBUFDIR/include"
    export CC="$(xcrun -sdk iphoneos -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$IPHONEOS_DEPLOYMENT_TARGET -I$pwd/headers"
    export AR=$(xcrun -sdk iphoneos -find ar)
    export RANLIB=$(xcrun -sdk iphoneos -find ranlib)
    export CPPFLAGS="-arch ${target}  -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$IPHONEOS_DEPLOYMENT_TARGET -I$pwd/headers"
    export LDFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk"

    mkdir -p $pwd/output/$target

    cd $pwd/mosh
    ./autogen.sh
    ./configure --prefix="$pwd/output/$target" --disable-server --disable-client --enable-ios-controller --host=$hosttarget-apple-darwin
    
    make clean
    make

    # ar + ranlib were superseded by libtool on OSX, so the makefile LIBADD won't work to create a single library
    libtool -static -o "$pwd/output/$target/libmoshios.a" \
	"$pwd/mosh/src/crypto/libmoshcrypto.a" "$pwd/mosh/src/network/libmoshnetwork.a" "$pwd/mosh/src/protobufs/libmoshprotos.a" \
	"$pwd/mosh/src/statesync/libmoshstatesync.a" "$pwd/mosh/src/terminal/libmoshterminal.a" "$pwd/mosh/src/frontend/libmoshiosclient.a" \
	"$pwd/mosh/src/util/libmoshutil.a"
}

findLatestSDKVersion iPhoneOS

mkdir headers
cd headers
for i in ncurses.h ncurses_dll.h unctrl.h curses.h term.h ; do
ln -s /usr/include/$i .
done
cd ..

#buildit i386 iPhoneSimulator
buildit x86_64 iPhoneSimulator
buildit arm64 iPhoneOS

LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshios.a $pwd/output/arm64/libmoshios.a -output $pwd/output/libmoshios.a
