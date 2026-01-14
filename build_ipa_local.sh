#!/bin/bash

# Local script to build IPA from extracted app bundle
# Usage: ./build_ipa_local.sh

set -e

EXTRACTED_DIR="extracted"
OUTPUT_DIR="output"
IPA_NAME="swiggy_device_rotator"

echo "🔨 Building IPA from app bundle..."

# Check if extracted directory exists
if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "❌ Error: $EXTRACTED_DIR directory not found"
    exit 1
fi

if [ ! -f "$EXTRACTED_DIR/Info.plist" ]; then
    echo "❌ Error: $EXTRACTED_DIR/Info.plist not found"
    exit 1
fi

# Determine app name
if command -v plutil &> /dev/null; then
    APP_NAME=$(plutil -extract CFBundleName raw "$EXTRACTED_DIR/Info.plist" 2>/dev/null || echo "Swiggy")
else
    # Fallback: try to get from plist using Python
    APP_NAME=$(python3 -c "
import plistlib
with open('$EXTRACTED_DIR/Info.plist', 'rb') as f:
    plist = plistlib.load(f)
    print(plist.get('CFBundleName', 'Swiggy'))
" 2>/dev/null || echo "Swiggy")
fi

# Ensure .app extension
if [[ ! "$APP_NAME" == *.app ]]; then
    APP_NAME="${APP_NAME}.app"
fi

echo "📱 App name: $APP_NAME"

# Create output directory
mkdir -p "$OUTPUT_DIR"
rm -rf "$OUTPUT_DIR/Payload"
rm -f "$OUTPUT_DIR"/*.ipa

# Create Payload structure
echo "📦 Creating Payload structure..."
mkdir -p "$OUTPUT_DIR/Payload"
cp -R "$EXTRACTED_DIR" "$OUTPUT_DIR/Payload/$APP_NAME"

# Create IPA
IPA_FILE="$OUTPUT_DIR/${IPA_NAME}_$(date +%Y%m%d_%H%M%S).ipa"
echo "📦 Creating IPA: $IPA_FILE"
cd "$OUTPUT_DIR"
zip -r "$(basename "$IPA_FILE")" Payload/ -x "*.DS_Store" "*/.*" "*/__MACOSX/*"
cd ..

echo ""
echo "✅ IPA created successfully!"
echo "📁 Location: $IPA_FILE"
echo ""
echo "⚠️  Next steps:"
echo "1. Sign the IPA with your certificate"
echo "2. Install on device using your preferred method"
echo ""
echo "To sign:"
echo "  unzip $IPA_FILE -d temp_sign"
echo "  codesign --force --sign \"YOUR_CERT\" --entitlements extracted/swiggy.entitlements \"temp_sign/Payload/$APP_NAME\""
echo "  cd temp_sign && zip -r ../signed_$(basename $IPA_FILE) Payload/"
