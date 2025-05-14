#!/bin/sh

#1
set -e

#2
swift build -c release --arch x86_64 --arch arm64
BUILD_PATH=$(swift build -c release --arch x86_64 --arch arm64 --show-bin-path)
echo -e "\n\nBuild at ${BUILD_PATH}"

#3
DESTINATION="builds/fawkes-macos"
if [ ! -d "builds" ]; then
    mkdir "builds"
fi

cp "$BUILD_PATH/fawkes" "$DESTINATION"
echo "Copied binary to $DESTINATION"
