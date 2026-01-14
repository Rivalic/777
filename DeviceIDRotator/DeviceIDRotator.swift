import Foundation
import UIKit

@objc public class DeviceIDRotator: NSObject {
    
    private static let deviceIDKey = "com.swiggy.customDeviceID"
    private static let shared = DeviceIDRotator()
    
    @objc public static func sharedInstance() -> DeviceIDRotator {
        return shared
    }
    
    /// Get the current custom device ID or generate a new one
    @objc public func getDeviceID() -> String {
        if let storedID = UserDefaults.standard.string(forKey: DeviceIDRotator.deviceIDKey) {
            return storedID
        }
        return generateNewDeviceID()
    }
    
    /// Generate a new UUID-based device ID
    @objc public func generateNewDeviceID() -> String {
        let newID = UUID().uuidString.lowercased()
        UserDefaults.standard.set(newID, forKey: DeviceIDRotator.deviceIDKey)
        UserDefaults.standard.synchronize()
        return newID
    }
    
    /// Rotate to a new device ID
    @objc public func rotateDeviceID() -> String {
        return generateNewDeviceID()
    }
    
    /// Get current device ID without generating new one
    @objc public func getCurrentDeviceID() -> String? {
        return UserDefaults.standard.string(forKey: DeviceIDRotator.deviceIDKey)
    }
    
    /// Clear stored device ID (will generate new on next get)
    @objc public func clearDeviceID() {
        UserDefaults.standard.removeObject(forKey: DeviceIDRotator.deviceIDKey)
        UserDefaults.standard.synchronize()
    }
}

// Hook for UIDevice.identifierForVendor
extension UIDevice {
    
    @objc static func swizzleIdentifierForVendor() {
        guard self == UIDevice.self else { return }
        
        let originalSelector = #selector(getter: UIDevice.identifierForVendor)
        let swizzledSelector = #selector(UIDevice.swizzled_identifierForVendor)
        
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(self,
                                          originalSelector,
                                          method_getImplementation(swizzledMethod),
                                          method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self,
                              swizzledSelector,
                              method_getImplementation(originalMethod),
                              method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc func swizzled_identifierForVendor() -> UUID? {
        // Return custom device ID as UUID
        let customID = DeviceIDRotator.sharedInstance().getDeviceID()
        return UUID(uuidString: customID)
    }
}

// Hook for ASIdentifierManager (Advertising Identifier)
@objc class ASIdentifierManagerHook: NSObject {
    
    @objc static func swizzleAdvertisingIdentifier() {
        // This would hook ASIdentifierManager if available
        // Note: Requires linking against AdSupport framework
    }
    
    @objc static func getAdvertisingIdentifier() -> String {
        return DeviceIDRotator.sharedInstance().getDeviceID()
    }
}
