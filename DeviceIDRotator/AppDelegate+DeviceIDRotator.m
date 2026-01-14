//
//  AppDelegate+DeviceIDRotator.m
//  Swiggy
//
//  Category to inject device ID rotation on app launch
//

#import <UIKit/UIKit.h>
#import "DeviceIDRotatorBridge.h"

@interface AppDelegate (DeviceIDRotator)
@end

@implementation AppDelegate (DeviceIDRotator)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [DeviceIDRotatorBridge setupDeviceIDRotation];
        NSLog(@"[DeviceIDRotator] Device ID rotation initialized");
    });
}

@end
