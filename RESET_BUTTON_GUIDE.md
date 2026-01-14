# Reset Device ID Button - Integration Guide

## ✅ What Has Been Added

A **"Reset Device ID"** button has been added to the Swiggy IPA that allows users to reset/rotate their device ID directly from within the app.

## 📁 Files Created

1. **`extracted/config/inject/reset_device_button.js`**
   - JavaScript injection script
   - Adds a floating button to web views
   - Handles device ID reset with UI feedback

2. **`DeviceIDRotatorDylib/DeviceIDResetButton.m`**
   - Native iOS component (optional, for dylib integration)
   - Adds button to native view controllers
   - Shows alert dialogs for reset confirmation

3. **`add_reset_button.py`**
   - Script to inject reset button into IPA
   - Automatically adds JavaScript to app bundle

## 🎯 How It Works

### JavaScript Injection Method (Implemented)

The reset button is added via JavaScript injection:

1. **Floating Button**: A fixed-position button appears in the bottom-right corner of web views
2. **Visual Design**: Orange gradient button with shadow effects
3. **Click Handler**: Shows confirmation dialog, then resets device ID
4. **Feedback**: Displays success notification with new device ID

### Button Features

- **Position**: Fixed at bottom-right (100px from bottom, 20px from right)
- **Style**: Orange gradient background, white text, rounded corners
- **Z-index**: 9999 (always on top)
- **Hover Effect**: Scales up slightly on hover
- **Auto-retry**: Periodically checks if button exists and recreates if needed

## 📱 Usage

### For Users

1. **Open the app** after installing the modified IPA
2. **Look for the button**: "🔄 Reset Device ID" button in bottom-right corner
3. **Click the button**: Confirmation dialog appears
4. **Confirm reset**: New device ID is generated
5. **Restart app**: Recommended for full effect

### Button Behavior

- **First Click**: Shows confirmation dialog
- **On Confirm**: Generates new device ID
- **Success**: Shows notification with new ID (first 8 characters)
- **Storage**: Device ID stored in localStorage (web) or UserDefaults (native)

## 🔧 Integration Details

### JavaScript Injection

The script is automatically injected into web views via:
- `config/inject/reset_device_button.js` - Main script
- Loaded automatically when web views initialize
- Works with existing `custom.js` injection system

### Native Integration (Optional)

If using the dylib approach:
- `DeviceIDResetButton.m` can be compiled into dylib
- Adds native UI buttons to view controllers
- Integrates with `DeviceIDRotator` dylib

## 📋 Implementation Status

✅ **JavaScript Button**: Implemented and added to IPA
✅ **Script Injection**: Added to `config/inject/` directory
✅ **IPA Modified**: `swiggy_with_reset_button.ipa` created
⏳ **Native Button**: Available but requires dylib compilation
⏳ **Signing**: IPA needs to be signed before installation

## 🚀 Next Steps

1. **Sign the IPA**:
   ```bash
   codesign --force --sign "YOUR_CERTIFICATE" \
     --entitlements extracted/swiggy.entitlements \
     Payload/Swiggy.app
   ```

2. **Install on Device**:
   - Use your preferred installation method
   - AltStore, Sideloadly, or direct installation

3. **Test the Button**:
   - Open the app
   - Navigate to any web view (settings, account, etc.)
   - Look for the reset button in bottom-right
   - Click to test reset functionality

## 🎨 Customization

### Button Position

Edit `reset_device_button.js`:
```javascript
bottom: 100px;  // Distance from bottom
right: 20px;    // Distance from right
```

### Button Style

Modify the `BUTTON_STYLE` constant:
```javascript
background: linear-gradient(135deg, #FF6B35 0%, #F7931E 100%);
color: white;
border-radius: 25px;
```

### Button Text

Change button label:
```javascript
button.textContent = '🔄 Reset Device ID';
```

## ⚠️ Important Notes

1. **Web Views Only**: JavaScript button works in web views (WKWebView)
2. **Native Views**: For native views, use the dylib approach
3. **Storage**: Device ID stored in localStorage (web) or UserDefaults (native)
4. **Restart**: App restart recommended after reset for full effect
5. **Signing**: IPA must be signed before installation

## 🐛 Troubleshooting

### Button Not Appearing

- Check browser console for errors
- Verify script is loaded: `config/inject/reset_device_button.js`
- Check if web view is blocking script injection
- Try different pages/screens in the app

### Reset Not Working

- Check localStorage/UserDefaults permissions
- Verify device ID storage key: `deviceID` or `com.swiggy.customDeviceID`
- Check console logs for errors
- Ensure dylib is loaded (if using native method)

### Button Overlaps Content

- Adjust position in script (bottom/right values)
- Change z-index if needed
- Modify button size if too large

## 📝 Code Examples

### Manual Reset (JavaScript)

```javascript
// Generate new device ID
const newID = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
});

// Store in localStorage
localStorage.setItem('deviceID', newID);
localStorage.setItem('deviceIDResetTime', new Date().toISOString());
```

### Manual Reset (Native)

```objc
#import "DeviceIDRotator.h"

// Rotate device ID
rotateDeviceID();

// Get current ID
const char *id = getCurrentDeviceID();
```

## 🔐 Security Considerations

- Device ID stored locally (not sent to server automatically)
- Reset requires user confirmation
- No automatic reset without user action
- Consider adding rate limiting for reset actions

## 📊 Files Modified

- ✅ `extracted/config/inject/reset_device_button.js` - Added
- ✅ `swiggy_with_reset_button.ipa` - Created with button
- ⏳ `DeviceIDRotatorDylib/DeviceIDResetButton.m` - Available for native integration

The reset button is now integrated into your IPA! Sign and install to test.
