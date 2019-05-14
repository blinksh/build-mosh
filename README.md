# build-mosh
Wrapper to compile Mosh for iOS. This is used to compile a library packaging Mosh to be used in [Blink](http://github.com/blinksh/blink). Please do not use it to compile mosh-client or mosh-server versions. Refer to the original [Mosh](https://github.com/mobile-shell/mosh) for that.

## Requirements
- XCode 7
- XCode Command Line Tools
- iOS SDK.

## Building
```bash
git clone --recursive https://github.com/blinksh/build-mosh.git && cd build-mosh
./build-all.sh
```

This script will build both Mosh and libprotobuf for iOS. The resulting Mosh for iOS will be packaged as libmoshios.framework on the root. The resulting libprotobuf.a will be under build-protobuf/protobuf-ver/lib.

If you want to customize the compilation of any piece, go to the corresopnding build-mosh or build-protobuf scripts.

Special thanks to @dariaphoebe for helping to simplify the compilation :)
