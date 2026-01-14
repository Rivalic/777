# Quick Start Guide - DeviceIDRotator Dylib

## 🚀 Fastest Way to Get Started

### Step 1: Build the Dylib

**On macOS:**
```bash
cd DeviceIDRotatorDylib
chmod +x build_dylib.sh
./build_dylib.sh
```

This creates `DeviceIDRotator.dylib` in the same directory.

### Step 2: Inject into IPA

**Option A: Using Python Script (if you have insert_dylib/optool)**
```bash
python inject_dylib.py ../swiggy.zip DeviceIDRotator.dylib swiggy_patched.ipa
```

**Option B: Manual Injection**

1. Extract IPA:
   ```bash
   unzip swiggy.zip -d temp_extract
   ```

2. Copy dylib:
   ```bash
   mkdir -p temp_extract/Payload/Swiggy.app/Frameworks
   cp DeviceIDRotator.dylib temp_extract/Payload/Swiggy.app/Frameworks/
   ```

3. Inject (requires insert_dylib or optool):
   ```bash
   # Download insert_dylib from: https://github.com/Tyilo/insert_dylib
   insert_dylib --weak --all-yes \
     @rpath/DeviceIDRotator.dylib \
     temp_extract/Payload/Swiggy.app/swiggy \
     temp_extract/Payload/Swiggy.app/swiggy.patched
   
   mv temp_extract/Payload/Swiggy.app/swiggy.patched \
      temp_extract/Payload/Swiggy.app/swiggy
   ```

4. Repackage:
   ```bash
   cd temp_extract
   zip -r ../swiggy_patched.ipa Payload/
   ```

### Step 3: Sign and Install

```bash
# Sign the IPA (replace with your certificate)
codesign --force --sign "YOUR_CERTIFICATE" \
  --entitlements ../extracted/swiggy.entitlements \
  temp_extract/Payload/Swiggy.app

# Repackage signed IPA
cd temp_extract
zip -r ../swiggy_signed.ipa Payload/
```

## 📋 What the Dylib Does

1. **Automatically hooks** `UIDevice.identifierForVendor` when app launches
2. **Stores custom device ID** in UserDefaults (`com.swiggy.customDeviceID`)
3. **Generates new UUID** on first launch or when rotated
4. **Provides C API** for programmatic access

## 🔧 Using the Rotator

The dylib works automatically - no code changes needed! Device ID methods will return the custom ID.

To rotate programmatically (if you add UI):

```objc
#import "DeviceIDRotator.h"

// Rotate device ID
rotateDeviceID();

// Get current device ID
const char *id = getCurrentDeviceID();
```

## ⚠️ Important Notes

- **Architecture:** Built for `arm64` (64-bit iOS devices)
- **Signing:** IPA must be re-signed after injection
- **Testing:** Test on a device, not simulator
- **Backup:** Keep original IPA as backup

## 🐛 Troubleshooting

**Build fails?**
- Make sure Xcode is installed: `xcode-select --install`
- Check SDK: `xcrun --sdk iphoneos --show-sdk-path`

**Injection fails?**
- Install insert_dylib: https://github.com/Tyilo/insert_dylib
- Or use optool: https://github.com/alexzielenski/optool
- Make sure app executable name is correct (may not be "swiggy")

**App crashes?**
- Check dylib is in Frameworks directory
- Verify dylib is properly signed
- Check console logs for loading errors

## 📱 Verification

After installation, verify dylib is loaded:

```bash
# Check if dylib is injected
otool -L Payload/Swiggy.app/swiggy | grep DeviceIDRotator

# Should show: @rpath/DeviceIDRotator.dylib
```

## 🎯 Next Steps

1. Build dylib ✅
2. Inject into IPA ✅
3. Sign IPA ✅
4. Install on device ✅
5. Test device ID rotation ✅

For more details, see `README_DYLIB.md`
