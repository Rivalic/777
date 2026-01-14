# IPA Signing Guide

## 🔐 Signing Methods

### Method 1: macOS with Xcode (Recommended)

**Requirements:**
- macOS computer
- Xcode installed
- Apple Developer account (free or paid)
- Code signing certificate

**Steps:**

1. **List available certificates:**
   ```bash
   security find-identity -v -p codesigning
   ```

2. **Sign the IPA:**
   ```bash
   chmod +x sign_ipa.sh
   ./sign_ipa.sh swiggy_with_reset_button.ipa "Apple Development: Your Name" extracted/swiggy.entitlements
   ```

3. **Or use Python script:**
   ```bash
   python sign_ipa.py swiggy_with_reset_button.ipa "Apple Development: Your Name" extracted/swiggy.entitlements
   ```

### Method 2: AltStore / Sideloadly (Easiest for Windows)

**Requirements:**
- Windows/Mac computer
- iOS device
- Apple ID (free)

**Steps:**

1. **Download AltStore:**
   - Visit: https://altstore.io
   - Install AltServer on your computer
   - Install AltStore on your iOS device

2. **Sign and Install:**
   - Open AltStore on your device
   - Tap "+" to add IPA
   - Select `swiggy_with_reset_button.ipa`
   - AltStore automatically signs and installs

**Or use Sideloadly:**
- Download: https://sideloadly.io
- Connect device
- Drag IPA into Sideloadly
- Enter Apple ID
- Click "Start" - automatic signing

### Method 3: Online Signing Services

**Popular Services:**
- AppDB: https://appdb.to
- Signulous: https://www.signulous.com
- ESign: https://esign.com

**Steps:**
1. Upload IPA to service
2. Pay for signing (usually $10-20/year)
3. Download signed IPA
4. Install via their app or direct link

### Method 4: Manual Signing (Advanced)

**On macOS:**

```bash
# Extract IPA
unzip swiggy_with_reset_button.ipa -d temp_sign

# Find app bundle
APP_BUNDLE="temp_sign/Payload/Swiggy.app"

# Remove old signatures
rm -rf "$APP_BUNDLE/_CodeSignature"
find "$APP_BUNDLE" -name "*.mobileprovision" -delete

# Sign frameworks
for framework in "$APP_BUNDLE/Frameworks"/*.framework; do
    codesign --force --sign "YOUR_CERT_NAME" "$framework"
done

# Sign plugins
for plugin in "$APP_BUNDLE/PlugIns"/*.appex; do
    codesign --force --sign "YOUR_CERT_NAME" "$plugin"
done

# Sign main app
codesign --force --sign "YOUR_CERT_NAME" \
  --entitlements extracted/swiggy.entitlements \
  "$APP_BUNDLE"

# Verify
codesign -vv --deep --strict "$APP_BUNDLE"

# Repackage
cd temp_sign
zip -r ../swiggy_signed.ipa Payload/
```

## 📋 Certificate Types

### Free Apple Developer Account
- **Certificate**: "Apple Development: Your Name"
- **Validity**: 7 days
- **Limit**: 3 apps per device
- **Cost**: Free

### Paid Apple Developer Account ($99/year)
- **Certificate**: "Apple Development" or "Apple Distribution"
- **Validity**: 1 year
- **Limit**: Unlimited apps
- **Cost**: $99/year

### Enterprise Certificate
- **Certificate**: "Apple Enterprise Distribution"
- **Validity**: 1 year
- **Limit**: Internal distribution only
- **Cost**: $299/year

## ⚠️ Important Notes

### Certificate Requirements

1. **Development Certificate**: For testing on your own devices
2. **Distribution Certificate**: For App Store or TestFlight
3. **Enterprise Certificate**: For internal company distribution

### Entitlements

The IPA includes entitlements file at `extracted/swiggy.entitlements`. Make sure to use it when signing to preserve app capabilities.

### Revocation

- Free certificates expire after 7 days
- Apps stop working when certificate expires
- Re-sign to continue using

### Device Trust

After installation:
1. Go to Settings > General > VPN & Device Management
2. Tap on your developer certificate
3. Tap "Trust [Your Name]"
4. Confirm trust

## 🐛 Troubleshooting

### "No valid code signing certificate found"

**Solution:**
- Create certificate in Xcode: Xcode > Preferences > Accounts > Manage Certificates
- Or use AltStore/Sideloadly (handles automatically)

### "Entitlements file not found"

**Solution:**
- Use the provided entitlements: `extracted/swiggy.entitlements`
- Or sign without entitlements (may lose some features)

### "App crashes after installation"

**Solution:**
- Check certificate is trusted (Settings > General > VPN & Device Management)
- Verify signature: `codesign -vv --deep --strict AppName.app`
- Re-sign with proper entitlements

### "Cannot install on device"

**Solution:**
- Check device UDID is registered (for development certs)
- Use AltStore/Sideloadly (handles UDID automatically)
- Verify iOS version compatibility

## 🔧 Verification

### Check Signature

```bash
# Verify app bundle
codesign -vv --deep --strict Payload/Swiggy.app

# Check entitlements
codesign -d --entitlements - Payload/Swiggy.app

# Verify IPA
codesign -vv --deep --strict swiggy_signed.ipa
```

### Expected Output

```
Payload/Swiggy.app: valid on disk
Payload/Swiggy.app: satisfies its Designated Requirement
```

## 📱 Installation Methods

### After Signing

1. **AltStore**: Drag IPA into AltStore app
2. **Sideloadly**: Drag IPA into Sideloadly
3. **3uTools**: Use IPA installation feature
4. **iTunes/Finder**: Drag to device (requires Apple Configurator)
5. **Direct Link**: Upload to server, download on device

## 💡 Recommendations

### For Testing (Free)
- **Use AltStore/Sideloadly** - Easiest, automatic signing
- Free Apple ID works
- 7-day certificate (auto-renewed)

### For Development
- **Use Xcode** - Full control, proper certificates
- Paid developer account recommended
- Better debugging capabilities

### For Distribution
- **Use TestFlight** - Official Apple method
- Requires paid developer account
- 90-day test period

## 📝 Quick Reference

**Windows Users:**
```bash
# Prepare IPA
python sign_ipa.py swiggy_with_reset_button.ipa

# Then use AltStore/Sideloadly to sign and install
```

**macOS Users:**
```bash
# Sign directly
./sign_ipa.sh swiggy_with_reset_button.ipa "Apple Development: Name" extracted/swiggy.entitlements
```

**All Platforms:**
- Use AltStore/Sideloadly for easiest signing experience

The signed IPA is ready to install on your device!
