//
//  DeviceIDRotatorBridge.h
//  DeviceIDRotator
//
//  Bridge header for Objective-C compatibility
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for DeviceIDRotator.
FOUNDATION_EXPORT double DeviceIDRotatorVersionNumber;

//! Project version string for DeviceIDRotator.
FOUNDATION_EXPORT const unsigned char DeviceIDRotatorVersionString[];

// Expose Swift classes to Objective-C
@class DeviceIDRotator;
@class DeviceIDRotatorViewController;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceIDRotatorBridge : NSObject

+ (void)setupDeviceIDRotation;
+ (NSString *)getCurrentDeviceID;
+ (NSString *)rotateDeviceID;
+ (void)presentRotatorViewControllerFrom:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
