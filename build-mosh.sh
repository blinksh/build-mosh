#!/bin/bash

PLATFORMPATH="/Applications/Xcode.app/Contents/Developer/Platforms"
TOOLSPATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
export IPHONEOS_DEPLOYMENT_TARGET="8.0"
pwd=`pwd`

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

    if [[ $hosttarget == "x86_64" ]]; then
	hostarget="i386"
    elif [[ $hosttarget == "arm64" ]]; then
	hosttarget="arm"
    fi

    export CC="$(xcrun -sdk iphoneos -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$SDKVERSION -I$pwd/headers"
    export AR=$(xcrun -sdk iphoneos -find ar)
    export RANLIB=$(xcrun -sdk iphoneos -find ranlib)
    export CPPFLAGS="-arch ${target}  -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$SDKVERSION"
    export LDFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk"

    mkdir -p $pwd/output/$target

    cd $pwd/mosh
    ./configure --prefix="$pwd/output/$target" --disable-server --disable-client --enable-ios-controller --host=$hosttarget-apple-darwin
    
    make clean
    make

    cp "$pwd/mosh/src/crypto/libmoshcrypto.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/network/libmoshnetwork.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/protobufs/libmoshprotos.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/statesync/libmoshstatesync.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/terminal/libmoshterminal.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/frontend/libmoshios.a" "$pwd/output/$target"
    cp "$pwd/mosh/src/util/libmoshutil.a" "$pwd/output/$target"
}

findLatestSDKVersion iPhoneOS

mkdir headers
cd headers
for i in ncurses.h ncurses_dll.h unctrl.h curses.h term.h ; do
ln -s /usr/include/$i .
done
cd ..

buildit i386 iPhoneSimulator
buildit x86_64 iPhoneSimulator
buildit arm64 iPhoneOS

LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshcrypto.a $pwd/output/i386/libmoshcrypto.a $pwd/output/arm64/libmoshcrypto.a  -output $pwd/output/libmoshcrypto.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshnetwork.a $pwd/output/i386/libmoshnetwork.a $pwd/output/arm64/libmoshnetwork.a -output $pwd/output/libmoshnetwork.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshprotos.a $pwd/output/i386/libmoshprotos.a $pwd/output/arm64/libmoshprotos.a -output $pwd/output/libmoshprotos.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshios.a $pwd/output/i386/libmoshios.a $pwd/output/arm64/libmoshios.a -output $pwd/output/libmoshios.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshstatesync.a $pwd/output/i386/libmoshstatesync.a $pwd/output/arm64/libmoshstatesync.a -output $pwd/output/libmoshstatesync.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshterminal.a $pwd/output/i386/libmoshterminal.a $pwd/output/arm64/libmoshterminal.a -output $pwd/output/libmoshterminal.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshutil.a $pwd/output/i386/libmoshutil.a $pwd/output/arm64/libmoshutil.a -output $pwd/output/libmoshutil.a
