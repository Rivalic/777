//
//  DeviceIDRotator.m
//  Device ID Rotator Dylib
//  Hooks into UIDevice to provide custom device ID rotation
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const kCustomDeviceIDKey = @"com.swiggy.customDeviceID";
static NSString *const kDeviceIDRotatorNotification = @"com.swiggy.deviceIDRotated";

// Original method implementations
static id (*original_identifierForVendor)(id, SEL);
static NSString *(*original_advertisingIdentifier)(id, SEL);

@interface DeviceIDRotator : NSObject
+ (NSString *)getCurrentDeviceID;
+ (NSString *)rotateDeviceID;
+ (NSString *)generateNewDeviceID;
@end

@implementation DeviceIDRotator

+ (NSString *)getCurrentDeviceID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedID = [defaults stringForKey:kCustomDeviceIDKey];
    
    if (!storedID) {
        storedID = [self generateNewDeviceID];
    }
    
    return storedID;
}

+ (NSString *)generateNewDeviceID {
    NSString *newID = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:newID forKey:kCustomDeviceIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceIDRotatorNotification 
                                                        object:newID];
    
    return newID;
}

+ (NSString *)rotateDeviceID {
    return [self generateNewDeviceID];
}

@end

// Hook for UIDevice.identifierForVendor
static NSUUID *swizzled_identifierForVendor(id self, SEL _cmd) {
    NSString *customID = [DeviceIDRotator getCurrentDeviceID];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:customID];
    return uuid;
}

// Hook for ASIdentifierManager (if available)
static NSString *swizzled_advertisingIdentifier(id self, SEL _cmd) {
    return [DeviceIDRotator getCurrentDeviceID];
}

// Constructor - runs when dylib is loaded
__attribute__((constructor))
static void init() {
    @autoreleasepool {
        NSLog(@"[DeviceIDRotator] Dylib loaded successfully");
        
        // Swizzle UIDevice.identifierForVendor
        Class deviceClass = objc_getClass("UIDevice");
        if (deviceClass) {
            Method originalMethod = class_getInstanceMethod(deviceClass, @selector(identifierForVendor));
            if (originalMethod) {
                original_identifierForVendor = (void *)method_getImplementation(originalMethod);
                method_setImplementation(originalMethod, (IMP)swizzled_identifierForVendor);
                NSLog(@"[DeviceIDRotator] Hooked UIDevice.identifierForVendor");
            }
        }
        
        // Try to hook ASIdentifierManager (for advertising identifier)
        Class asIdentifierClass = objc_getClass("ASIdentifierManager");
        if (asIdentifierClass) {
            Method adMethod = class_getInstanceMethod(asIdentifierClass, @selector(advertisingIdentifier));
            if (adMethod) {
                original_advertisingIdentifier = (void *)method_getImplementation(adMethod);
                method_setImplementation(adMethod, (IMP)swizzled_advertisingIdentifier);
                NSLog(@"[DeviceIDRotator] Hooked ASIdentifierManager.advertisingIdentifier");
            }
        }
        
        // Initialize with a device ID if none exists
        [DeviceIDRotator getCurrentDeviceID];
        
        NSLog(@"[DeviceIDRotator] Initialization complete. Current Device ID: %@", 
              [DeviceIDRotator getCurrentDeviceID]);
    }
}

// Export functions for external access
void rotateDeviceID(void) {
    [DeviceIDRotator rotateDeviceID];
}

const char* getCurrentDeviceID(void) {
    NSString *deviceID = [DeviceIDRotator getCurrentDeviceID];
    return [deviceID UTF8String];
}
