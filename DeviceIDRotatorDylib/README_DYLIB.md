# DeviceIDRotator Dylib

A dynamic library (dylib) that hooks into iOS device ID methods to enable device ID rotation for the Swiggy app.

## 🎯 Features

- ✅ Hooks `UIDevice.identifierForVendor`
- ✅ Hooks `ASIdentifierManager.advertisingIdentifier` (if available)
- ✅ Stores custom device ID in UserDefaults
- ✅ Automatic initialization on app launch
- ✅ C API for external access

## 📁 Files

- `DeviceIDRotator.m` - Main dylib implementation
- `DeviceIDRotator.h` - Header file with C API
- `Makefile` - Theos build configuration (optional)
- `build_dylib.sh` - Simple build script
- `inject_dylib.py` - Script to inject dylib into IPA

## 🔨 Building the Dylib

### Prerequisites

- macOS with Xcode installed
- Command Line Tools: `xcode-select --install`
- iOS SDK (comes with Xcode)

### Method 1: Simple Build Script (Recommended)

```bash
cd DeviceIDRotatorDylib
chmod +x build_dylib.sh
./build_dylib.sh
```

This will create `DeviceIDRotator.dylib` in the same directory.

### Method 2: Manual Build

```bash
cd DeviceIDRotatorDylib

# Get iOS SDK path
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)

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
```

### Method 3: Using Theos (Advanced)

If you have Theos installed:

```bash
cd DeviceIDRotatorDylib
make
```

## 📦 Injecting into IPA

### Option 1: Using Python Script

```bash
python inject_dylib.py swiggy.ipa DeviceIDRotator.dylib swiggy_patched.ipa
```

**Note:** This script requires `insert_dylib` or `optool` for automatic injection. If not available, it will copy the dylib but you'll need to inject manually.

### Option 2: Manual Injection

1. **Extract IPA:**
   ```bash
   unzip swiggy.ipa -d temp_extract
   ```

2. **Copy dylib to Frameworks:**
   ```bash
   cp DeviceIDRotator.dylib temp_extract/Payload/Swiggy.app/Frameworks/
   ```

3. **Inject using insert_dylib:**
   ```bash
   # Download insert_dylib from: https://github.com/Tyilo/insert_dylib
   insert_dylib --weak --all-yes \
     @rpath/DeviceIDRotator.dylib \
     temp_extract/Payload/Swiggy.app/swiggy \
     temp_extract/Payload/Swiggy.app/swiggy.patched
   
   mv temp_extract/Payload/Swiggy.app/swiggy.patched \
      temp_extract/Payload/Swiggy.app/swiggy
   ```

4. **Or use optool:**
   ```bash
   # Download optool from: https://github.com/alexzielenski/optool
   optool install -c load \
     -p @rpath/DeviceIDRotator.dylib \
     -t temp_extract/Payload/Swiggy.app/swiggy
   ```

5. **Add rpath (if needed):**
   ```bash
   install_name_tool -add_rpath @executable_path/Frameworks \
     temp_extract/Payload/Swiggy.app/swiggy
   ```

6. **Repackage IPA:**
   ```bash
   cd temp_extract
   zip -r ../swiggy_patched.ipa Payload/
   ```

## 🔧 How It Works

1. **Constructor Function:** The dylib uses `__attribute__((constructor))` to run code when loaded
2. **Method Swizzling:** Hooks into `UIDevice.identifierForVendor` using runtime method replacement
3. **Storage:** Stores custom device ID in `NSUserDefaults` with key `com.swiggy.customDeviceID`
4. **UUID Generation:** Creates new UUIDs when rotating device ID

## 📱 Usage in App

The dylib automatically hooks device ID methods. To rotate device ID programmatically:

```objc
#import "DeviceIDRotator.h"

// Rotate device ID
rotateDeviceID();

// Get current device ID
const char *deviceID = getCurrentDeviceID();
NSString *deviceIDString = [NSString stringWithUTF8String:deviceID];
```

## 🔍 Verification

After injection, check if dylib is loaded:

```bash
# Check dylib dependencies
otool -L Payload/Swiggy.app/swiggy | grep DeviceIDRotator

# Check if dylib is injected
otool -l Payload/Swiggy.app/swiggy | grep -A 5 LC_LOAD_DYLIB
```

## ⚠️ Important Notes

1. **Signing:** The IPA must be re-signed after injection
2. **Architecture:** Dylib is built for `arm64` (64-bit devices)
3. **iOS Version:** Requires iOS 15.0+ (can be adjusted in build script)
4. **Code Signing:** Dylib must be signed or have proper entitlements

## 🐛 Troubleshooting

### Build Fails: "SDK not found"
- Install Xcode Command Line Tools: `xcode-select --install`
- Verify SDK: `xcrun --sdk iphoneos --show-sdk-path`

### Injection Fails
- Ensure `insert_dylib` or `optool` is installed and in PATH
- Check app executable name matches (may not be "swiggy")
- Verify dylib is in Frameworks directory

### App Crashes After Injection
- Check dylib is properly signed
- Verify architecture matches (arm64)
- Check console logs for dylib loading errors

## 📝 API Reference

### C Functions

```c
// Rotate to a new device ID
void rotateDeviceID(void);

// Get current device ID (returns C string)
const char* getCurrentDeviceID(void);
```

### Objective-C Class

```objc
@interface DeviceIDRotator : NSObject
+ (NSString *)getCurrentDeviceID;
+ (NSString *)rotateDeviceID;
+ (NSString *)generateNewDeviceID;
@end
```

## 🔐 Security Considerations

- Dylib modifies system APIs at runtime
- Device ID is stored in UserDefaults (can be cleared)
- Requires app to be re-signed after injection
- May be detected by security frameworks

## 📄 License

Use responsibly and in accordance with applicable terms of service.
