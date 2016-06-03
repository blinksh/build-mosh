# build-mosh
Wrapper to compile Mosh for iOS. This is used to compile a library packaging Mosh to be used in [Blink](http://github.com/blinksh/blink). Please do not use it to compile mosh-client or mosh-server versions. Refer to the original [Mosh](https://github.com/mobile-shell/mosh) for that.

## Requirements
- XCode 7
- XCode Command Line Tools
- iOS SDK.

## Building
- Checkout submodules
```bash
git submodule init
git submodule update
```

- Compile
Enable / Disable architectures from the build-mosh.sh file by commenting / uncommenting the "buildit" lines. Current supported architectures are arm64 and x86_64 due to threading code support.

To compile, just run: ./build-mosh.sh

Output library files will be generated on the output folder. Lipo files grouping all the architectures will be created at the root, while you can also access each architecture on the corresponding folder. For installation in Blink, please copy only the Lipo files.