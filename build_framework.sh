#!/bin/bash

# Build script for DeviceIDRotator framework
# Usage: ./build_framework.sh

set -e

FRAMEWORK_NAME="DeviceIDRotator"
BUILD_DIR="build"
OUTPUT_DIR="output"

echo "🔨 Building DeviceIDRotator Framework..."

# Clean previous builds
rm -rf "$BUILD_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Check if we're in an Xcode project directory
if [ -f "DeviceIDRotator.xcodeproj/project.pbxproj" ]; then
    echo "📦 Building with Xcode..."
    
    # Build for device
    xcodebuild clean build \
        -project DeviceIDRotator.xcodeproj \
        -scheme DeviceIDRotator \
        -configuration Release \
        -sdk iphoneos \
        ARCHS=arm64 \
        VALID_ARCHS=arm64 \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        BUILD_DIR="$BUILD_DIR"
    
    # Copy framework
    cp -R "$BUILD_DIR/Release-iphoneos/$FRAMEWORK_NAME.framework" "$OUTPUT_DIR/"
    
    echo "✅ Framework built successfully!"
    echo "📁 Output: $OUTPUT_DIR/$FRAMEWORK_NAME.framework"
    
else
    echo "⚠️  Xcode project not found."
    echo "📝 Creating framework structure manually..."
    
    # Create framework structure
    FRAMEWORK_PATH="$OUTPUT_DIR/$FRAMEWORK_NAME.framework"
    mkdir -p "$FRAMEWORK_PATH/Headers"
    mkdir -p "$FRAMEWORK_PATH/Modules"
    
    # Copy headers
    cp DeviceIDRotator/DeviceIDRotatorBridge.h "$FRAMEWORK_PATH/Headers/"
    
    # Create module map
    cat > "$FRAMEWORK_PATH/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "DeviceIDRotatorBridge.h"
    export *
    module * { export * }
}
EOF
    
    # Copy Info.plist
    cp DeviceIDRotator/Info.plist "$FRAMEWORK_PATH/"
    
    echo "⚠️  Manual framework structure created."
    echo "⚠️  You need to compile Swift files separately and add the binary."
    echo "📁 Output: $FRAMEWORK_PATH"
fi

echo ""
echo "📋 Next steps:"
echo "1. Copy framework to: extracted/Payload/Swiggy.app/Frameworks/"
echo "2. Run integration script: python integrate_device_rotator.py swiggy.zip"
echo "3. Re-sign the IPA with your certificate"
