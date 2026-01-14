#!/bin/bash

# Quick integration script for Swiggy IPA
# This script extracts, integrates, and repackages the IPA

set -e

IPA_FILE="${1:-swiggy.zip}"
OUTPUT_IPA="${2:-swiggy_device_rotator.ipa}"
EXTRACT_DIR="temp_integration"

echo "🚀 Starting Device ID Rotator Integration..."

# Clean up
if [ -d "$EXTRACT_DIR" ]; then
    rm -rf "$EXTRACT_DIR"
fi

# Extract IPA
echo "📦 Extracting $IPA_FILE..."
if [[ "$IPA_FILE" == *.zip ]]; then
    unzip -q "$IPA_FILE" -d "$EXTRACT_DIR"
else
    unzip -q "$IPA_FILE" -d "$EXTRACT_DIR"
fi

# Find app directory
APP_DIR=$(find "$EXTRACT_DIR" -name "*.app" -type d | head -1)
if [ -z "$APP_DIR" ]; then
    echo "❌ Error: Could not find .app directory"
    exit 1
fi

echo "📱 Found app: $APP_DIR"

# Create Frameworks directory if it doesn't exist
FRAMEWORKS_DIR="$APP_DIR/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"

# Check if framework exists
FRAMEWORK_PATH="output/DeviceIDRotator.framework"
if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "⚠️  Warning: Framework not found at $FRAMEWORK_PATH"
    echo "⚠️  Please build the framework first using: ./build_framework.sh"
    echo "⚠️  Continuing with integration (you'll need to add framework manually)..."
else
    # Copy framework
    echo "📋 Copying framework..."
    cp -R "$FRAMEWORK_PATH" "$FRAMEWORKS_DIR/"
    echo "✅ Framework copied"
fi

# Create config/inject directory
CONFIG_DIR="$APP_DIR/config/inject"
mkdir -p "$CONFIG_DIR"

# Create device rotator injection script
cat > "$CONFIG_DIR/device_rotator.js" << 'EOF'
// Device ID Rotator Injection Script
(function() {
    function addRotatorButton() {
        const button = document.createElement('button');
        button.textContent = '🔄 Rotate Device ID';
        button.style.cssText = 'padding: 12px 24px; background: #FF6B35; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin: 20px; font-weight: bold;';
        button.onclick = function() {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.deviceIDRotator) {
                window.webkit.messageHandlers.deviceIDRotator.postMessage({action: 'rotate'});
            } else {
                alert('Device ID rotation requires native app support. Please use the native settings.');
            }
        };
        
        const settingsContainer = document.querySelector('.settings-container') || 
                                  document.querySelector('[class*="Settings"]') ||
                                  document.querySelector('body');
        if (settingsContainer) {
            const existingButton = settingsContainer.querySelector('[data-device-rotator]');
            if (!existingButton) {
                button.setAttribute('data-device-rotator', 'true');
                settingsContainer.insertBefore(button, settingsContainer.firstChild);
            }
        }
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', addRotatorButton);
    } else {
        addRotatorButton();
    }
    
    setTimeout(addRotatorButton, 1000);
    setTimeout(addRotatorButton, 3000);
})();
EOF

echo "✅ Injection script created"

# Repackage IPA
echo "📦 Repackaging IPA..."
cd "$EXTRACT_DIR"
zip -q -r "../$OUTPUT_IPA" Payload/ 2>/dev/null || zip -q -r "../$OUTPUT_IPA" ./*
cd ..

# Clean up
rm -rf "$EXTRACT_DIR"

echo ""
echo "✅ Integration complete!"
echo "📱 Output IPA: $OUTPUT_IPA"
echo ""
echo "⚠️  Important:"
echo "1. Sign the IPA with your certificate before installing"
echo "2. The framework must be properly built and signed"
echo "3. Restart the app after rotating device ID for full effect"
