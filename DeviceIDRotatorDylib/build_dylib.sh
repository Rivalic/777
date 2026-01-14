#!/bin/bash

# Build script for DeviceIDRotator dylib
# Usage: ./build_dylib.sh

set -e

SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || echo "")
if [ -z "$SDK_PATH" ]; then
    echo "❌ Error: iOS SDK not found. Make sure Xcode is installed."
    exit 1
fi

echo "🔨 Building DeviceIDRotator.dylib..."
echo "📱 SDK Path: $SDK_PATH"

# Clean previous build
rm -f DeviceIDRotator.dylib

# Build dylib
clang -arch arm64 \
    -isysroot "$SDK_PATH" \
    -framework UIKit \
    -framework Foundation \
    -dynamiclib \
    -fobjc-arc \
    -install_name @rpath/DeviceIDRotator.dylib \
    -compatibility_version 1.0 \
    -current_version 1.0 \
    -o DeviceIDRotator.dylib \
    DeviceIDRotator.m

if [ -f DeviceIDRotator.dylib ]; then
    echo "✅ Build successful!"
    echo "📁 Output: DeviceIDRotator.dylib"
    ls -lh DeviceIDRotator.dylib
    
    # Show dylib info
    echo ""
    echo "📋 Dylib Info:"
    otool -L DeviceIDRotator.dylib | head -5
    
    echo ""
    echo "📋 Exported Symbols:"
    nm -gU DeviceIDRotator.dylib | grep -E "(rotateDeviceID|getCurrentDeviceID)" || echo "No exported symbols found"
else
    echo "❌ Build failed!"
    exit 1
fi
