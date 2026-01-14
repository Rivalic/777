#!/bin/bash

# Script to sign Swiggy IPA
# Usage: ./sign_ipa.sh <ipa_file> <certificate_name> [entitlements_file]

set -e

if [ $# -lt 2 ]; then
    echo "Usage: ./sign_ipa.sh <ipa_file> <certificate_name> [entitlements_file]"
    echo ""
    echo "Example:"
    echo "  ./sign_ipa.sh swiggy_with_reset_button.ipa \"Apple Development: Your Name\" extracted/swiggy.entitlements"
    echo ""
    echo "Available certificates:"
    security find-identity -v -p codesigning | grep ")" | head -10
    exit 1
fi

IPA_FILE="$1"
CERT_NAME="$2"
ENTITLEMENTS="${3:-extracted/swiggy.entitlements}"

if [ ! -f "$IPA_FILE" ]; then
    echo "Error: IPA file not found: $IPA_FILE"
    exit 1
fi

if [ ! -f "$ENTITLEMENTS" ]; then
    echo "Warning: Entitlements file not found: $ENTITLEMENTS"
    echo "Continuing without entitlements..."
    ENTITLEMENTS=""
fi

OUTPUT_IPA="${IPA_FILE%.ipa}_signed.ipa"
TEMP_DIR="temp_sign_$(date +%s)"

echo "=========================================="
echo "Signing IPA: $IPA_FILE"
echo "Certificate: $CERT_NAME"
echo "Entitlements: ${ENTITLEMENTS:-None}"
echo "=========================================="
echo ""

# Extract IPA
echo "[1/5] Extracting IPA..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
unzip -q "$IPA_FILE" -d "$TEMP_DIR"

# Find app bundle
APP_BUNDLE=$(find "$TEMP_DIR" -name "*.app" -type d | head -1)

if [ -z "$APP_BUNDLE" ]; then
    echo "Error: Could not find .app bundle in IPA"
    exit 1
fi

echo "[2/5] Found app bundle: $(basename "$APP_BUNDLE")"

# Remove existing signatures
echo "[3/5] Removing existing signatures..."
find "$APP_BUNDLE" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
find "$APP_BUNDLE" -name "*.mobileprovision" -delete 2>/dev/null || true

# Sign frameworks and plugins
echo "[4/5] Signing frameworks and plugins..."

# Sign all frameworks
if [ -d "$APP_BUNDLE/Frameworks" ]; then
    for framework in "$APP_BUNDLE/Frameworks"/*.framework; do
        if [ -d "$framework" ]; then
            echo "  Signing framework: $(basename "$framework")"
            if [ -n "$ENTITLEMENTS" ]; then
                codesign --force --sign "$CERT_NAME" --entitlements "$ENTITLEMENTS" "$framework" 2>/dev/null || \
                codesign --force --sign "$CERT_NAME" "$framework"
            else
                codesign --force --sign "$CERT_NAME" "$framework"
            fi
        fi
    done
fi

# Sign all plugins/extensions
if [ -d "$APP_BUNDLE/PlugIns" ]; then
    for plugin in "$APP_BUNDLE/PlugIns"/*.appex; do
        if [ -d "$plugin" ]; then
            echo "  Signing plugin: $(basename "$plugin")"
            if [ -n "$ENTITLEMENTS" ]; then
                codesign --force --sign "$CERT_NAME" --entitlements "$ENTITLEMENTS" "$plugin" 2>/dev/null || \
                codesign --force --sign "$CERT_NAME" "$plugin"
            else
                codesign --force --sign "$CERT_NAME" "$plugin"
            fi
        fi
    done
fi

# Sign the main app bundle
echo "[5/5] Signing main app bundle..."
if [ -n "$ENTITLEMENTS" ]; then
    codesign --force --sign "$CERT_NAME" --entitlements "$ENTITLEMENTS" "$APP_BUNDLE"
else
    codesign --force --sign "$CERT_NAME" "$APP_BUNDLE"
fi

# Verify signature
echo ""
echo "Verifying signature..."
codesign -vv --deep --strict "$APP_BUNDLE" && echo "✅ Signature verified!" || echo "⚠️  Signature verification failed"

# Repackage IPA
echo ""
echo "Repackaging IPA..."
cd "$TEMP_DIR"
zip -q -r "../$OUTPUT_IPA" Payload/
cd ..

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "✅ IPA signed successfully!"
echo "📁 Output: $OUTPUT_IPA"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Verify the signed IPA: codesign -vv --deep --strict $OUTPUT_IPA"
echo "2. Install on device using your preferred method"
echo "3. Trust the certificate on your device (Settings > General > VPN & Device Management)"
