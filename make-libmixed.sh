#!/bin/sh
set -e

if [ -d ./libmixed ]; then
    # Clean
    rm -rf libmixed/build
else 
    # Download source
    git clone https://github.com/Shirakumo/libmixed.git
fi

# Configure NDK.
if [ -z $NDK ]; then
    echo "Please set NDK path variable." && exit 1
fi
if [ -z $ABI ]; then
    echo "Running adb to determine target ABI..."
    ABI=`adb shell uname -m`
    echo $ABI
fi
case $ABI in
    arm64) ABI=arm64-v8a ;;
    aarch64) ABI=arm64-v8a ;;
    arm64-v8a) ;;
    arm) ABI=armeabi-v7a ;;
    armeabi-v7a) ;;
    x86) ;;
    x86-64) ABI=x86_64 ;;
    x86_64) ;;
    all)
        ABI=arm64  ./make-libmixed.sh
        ABI=arm    ./make-libmixed.sh
        ABI=x86    ./make-libmixed.sh
        ABI=x86-64 ./make-libmixed.sh
        echo "Done."
        exit 0 ;;
    *) echo "Unsupported CPU ABI" && exit 1 ;;
esac

if [ -z $API ]; then
    echo "Android API not set. Using 21 by default."
    API=21
fi

(
cd libmixed ;
mkdir build && cd build ;
cmake \
    -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ABI \
    -DANDROID_PLATFORM=android-$API \
    .. ;
make
)

# Copy shared library
mkdir -p lib/$ABI
cp libmixed/build/libmixed.so lib/$ABI/
# ...and headers
# no headers
