#!/bin/sh

set -e

swift build -c release
BUILD_PATH=$(swift build -c release --show-bin-path)
echo -e "\n\nBuild at ${BUILD_PATH}"

DESTINATION="builds/fawkes-linux"
if [ ! -d "builds" ]; then
    mkdir "builds"
fi

cp "$BUILD_PATH/fawkes" "$DESTINATION"
echo "Copied binary to $DESTINATION"
