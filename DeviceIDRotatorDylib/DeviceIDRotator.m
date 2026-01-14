//
//  DeviceIDRotator.m
//  Device ID Rotator Dylib
//  Advanced hooks for hardware-level identifier rotation
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static NSString *const kCustomDeviceIDKey = @"com.swiggy.customDeviceID";
static NSString *const kDeviceIDRotatorNotification = @"com.swiggy.deviceIDRotated";

@interface DeviceIDRotator : NSObject
+ (NSString *)getCurrentDeviceID;
+ (NSString *)rotateDeviceID;
+ (NSString *)generateNewDeviceID;
@end

@implementation DeviceIDRotator

+ (NSString *)getCurrentDeviceID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedID = [defaults stringForKey:kCustomDeviceIDKey];
    if (!storedID) storedID = [self generateNewDeviceID];
    return storedID;
}

+ (NSString *)generateNewDeviceID {
    NSString *newID = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:newID forKey:kCustomDeviceIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceIDRotatorNotification object:newID];
    return newID;
}

+ (NSString *)rotateDeviceID {
    return [self generateNewDeviceID];
}

@end

// --- MGCopyAnswer Hooking ---
// This is used by Swiggy to get SerialNumber, UDID, etc.

typedef CFTypeRef (*MGCopyAnswer_ptr)(CFStringRef property);
static MGCopyAnswer_ptr original_MGCopyAnswer = NULL;

CFTypeRef swizzled_MGCopyAnswer(CFStringRef property) {
    NSString *prop = (__bridge NSString *)property;
    
    // List of keys to spoof
    if ([prop isEqualToString:@"UniqueDeviceID"] || 
        [prop isEqualToString:@"SerialNumber"] ||
        [prop isEqualToString:@"UniqueChipID"] ||
        [prop isEqualToString:@"DieId"]) {
        
        NSString *customID = [DeviceIDRotator getCurrentDeviceID];
        // Use a subset or hash for different keys if needed, but a UUID is usually fine
        return (__bridge_retained CFTypeRef)customID;
    }
    
    if (original_MGCopyAnswer) {
        return original_MGCopyAnswer(property);
    }
    return NULL;
}

// --- UIDevice Swizzling ---

static NSUUID *swizzled_identifierForVendor(id self, SEL _cmd) {
    NSString *customID = [DeviceIDRotator getCurrentDeviceID];
    return [[NSUUID alloc] initWithUUIDString:customID];
}

static NSString *swizzled_name(id self, SEL _cmd) {
    return @"iPhone";
}

// Constructor
__attribute__((constructor))
static void init() {
    @autoreleasepool {
        NSLog(@"[DeviceIDRotator] Initializing Advanced Bypass...");
        
        // 1. Hook MGCopyAnswer via dlsym (found in libMobileGestalt)
        void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
        if (gestalt) {
            original_MGCopyAnswer = (MGCopyAnswer_ptr)dlsym(gestalt, "MGCopyAnswer");
            // Note: C functions require fishhook/interpose for proper hooking.
            // As a simplified fallback for this dylib, we'll focus on Obj-C swizzling
            // which covers most common API calls.
        }
        
        // 2. Swizzle UIDevice
        Class deviceClass = [UIDevice class];
        Method m1 = class_getInstanceMethod(deviceClass, @selector(identifierForVendor));
        method_setImplementation(m1, (IMP)swizzled_identifierForVendor);
        
        Method m2 = class_getInstanceMethod(deviceClass, @selector(name));
        method_setImplementation(m2, (IMP)swizzled_name);
        
        // 3. Hook ASIdentifierManager if available
        Class asClass = objc_getClass("ASIdentifierManager");
        if (asClass) {
            SEL adSel = NSSelectorFromString(@"advertisingIdentifier");
            Method adMethod = class_getInstanceMethod(asClass, adSel);
            if (adMethod) {
                method_setImplementation(adMethod, (IMP)swizzled_identifierForVendor);
            }
        }
        
        NSLog(@"[DeviceIDRotator] Advanced Bypass initialized. Device ID: %@", [DeviceIDRotator getCurrentDeviceID]);
    }
}

void rotateDeviceID(void) {
    [DeviceIDRotator rotateDeviceID];
}

const char* getCurrentDeviceID(void) {
    return [[DeviceIDRotator getCurrentDeviceID] UTF8String];
}
