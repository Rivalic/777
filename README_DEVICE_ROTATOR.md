# Device ID Rotator for Swiggy IPA

This project adds device ID rotation functionality to the Swiggy iOS app with a user-friendly interface.

## Features

- 🔄 Rotate device ID with a single button tap
- 📋 Copy device ID to clipboard
- 🎨 Modern, native iOS UI
- 🔒 Stores device ID in UserDefaults
- 🪝 Hooks into UIDevice.identifierForVendor

## Project Structure

```
DeviceIDRotator/
├── DeviceIDRotator.swift              # Core rotation logic
├── DeviceIDRotatorViewController.swift # UI with rotate button
├── DeviceIDRotatorBridge.h            # Objective-C bridge header
├── DeviceIDRotatorBridge.m            # Objective-C bridge implementation
├── AppDelegate+DeviceIDRotator.m      # App launch injection
└── Info.plist                         # Framework Info.plist

integrate_device_rotator.py            # Integration script
```

## Building the Framework

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ SDK
- macOS with Xcode Command Line Tools

### Steps

1. **Create a new Framework project in Xcode:**
   ```bash
   # Open Xcode and create a new project
   # Choose: Framework > iOS
   # Name: DeviceIDRotator
   ```

2. **Add the source files:**
   - Copy all Swift files to the framework project
   - Copy the Objective-C bridge files
   - Add Info.plist

3. **Configure Build Settings:**
   - Set `DEFINES_MODULE` to `YES`
   - Set `SWIFT_OBJC_INTERFACE_HEADER_NAME` to `DeviceIDRotator-Swift.h`
   - Set `PRODUCT_MODULE_NAME` to `DeviceIDRotator`

4. **Build the framework:**
   ```bash
   xcodebuild -project DeviceIDRotator.xcodeproj \
              -scheme DeviceIDRotator \
              -configuration Release \
              -sdk iphoneos \
              ARCHS=arm64 \
              CODE_SIGN_IDENTITY="" \
              CODE_SIGNING_REQUIRED=NO \
              CODE_SIGNING_ALLOWED=NO
   ```

5. **Copy the framework:**
   ```bash
   cp -R build/Release-iphoneos/DeviceIDRotator.framework /path/to/swiggy/Payload/Swiggy.app/Frameworks/
   ```

## Integration into IPA

### Method 1: Using the Python Script

```bash
# Extract and integrate
python integrate_device_rotator.py swiggy.zip swiggy_patched.ipa

# Then manually copy the built framework to:
# Payload/Swiggy.app/Frameworks/DeviceIDRotator.framework
```

### Method 2: Manual Integration

1. **Extract the IPA:**
   ```bash
   unzip swiggy.zip -d extracted/
   ```

2. **Copy the framework:**
   ```bash
   cp -R DeviceIDRotator.framework extracted/Payload/Swiggy.app/Frameworks/
   ```

3. **Add injection script:**
   ```bash
   mkdir -p extracted/Payload/Swiggy.app/config/inject
   cp DeviceIDRotator/injection_script.js extracted/Payload/Swiggy.app/config/inject/
   ```

4. **Repackage:**
   ```bash
   cd extracted/
   zip -r ../swiggy_device_rotator.ipa Payload/
   ```

## Usage in App

### Programmatic Access

```swift
// Get current device ID
let deviceID = DeviceIDRotator.sharedInstance().getDeviceID()

// Rotate device ID
let newID = DeviceIDRotator.sharedInstance().rotateDeviceID()

// Present UI
let rotatorVC = DeviceIDRotatorViewController()
present(rotatorVC, animated: true)
```

### From Any View Controller

```swift
// Present the rotator UI
self.presentDeviceIDRotator()
```

### From Objective-C

```objc
#import "DeviceIDRotatorBridge.h"

// Setup (call in AppDelegate)
[DeviceIDRotatorBridge setupDeviceIDRotation];

// Get device ID
NSString *deviceID = [DeviceIDRotatorBridge getCurrentDeviceID];

// Rotate device ID
NSString *newID = [DeviceIDRotatorBridge rotateDeviceID];

// Present UI
[DeviceIDRotatorBridge presentRotatorViewControllerFrom:self];
```

## UI Features

The `DeviceIDRotatorViewController` provides:

- **Device ID Display**: Shows current device ID in a readable format
- **Copy Button**: Copies device ID to clipboard
- **Rotate Button**: Generates a new device ID
- **Status Messages**: Visual feedback for actions

## How It Works

1. **Device ID Storage**: Uses `UserDefaults` to persist custom device IDs
2. **Method Swizzling**: Hooks into `UIDevice.identifierForVendor` to return custom ID
3. **UUID Generation**: Creates new UUIDs in standard format (lowercase, hyphenated)
4. **UI Integration**: Provides native iOS interface for easy access

## Important Notes

⚠️ **Restart Required**: After rotating device ID, restart the app for changes to take full effect.

⚠️ **Signing**: After modifying the IPA, you'll need to re-sign it with your certificate:
```bash
codesign --force --sign "Your Certificate" --entitlements swiggy.entitlements Payload/Swiggy.app
```

⚠️ **Framework Loading**: The framework must be properly signed and included in the app's Frameworks directory.

## Troubleshooting

### Framework not loading
- Ensure framework is in `Frameworks/` directory
- Check framework is properly signed
- Verify `Info.plist` includes framework reference

### Device ID not rotating
- Check UserDefaults permissions
- Verify method swizzling is called on app launch
- Ensure framework is loaded before first device ID access

### UI not appearing
- Check that view controller is properly initialized
- Verify navigation controller setup
- Ensure proper view hierarchy

## License

This is a modification tool for educational purposes. Use responsibly and in accordance with applicable terms of service.

## Support

For issues or questions, check:
- Framework build logs
- Xcode console output
- Device logs via Console.app
