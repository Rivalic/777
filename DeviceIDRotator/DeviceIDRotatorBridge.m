//
//  DeviceIDRotatorBridge.m
//  DeviceIDRotator
//
//  Bridge implementation
//

#import "DeviceIDRotatorBridge.h"
#import <DeviceIDRotator-Swift.h>

@implementation DeviceIDRotatorBridge

+ (void)setupDeviceIDRotation {
    // Initialize swizzling
    [UIDevice swizzleIdentifierForVendor];
    
    // Setup notification to present rotator
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PresentDeviceIDRotator" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        UIViewController *presentingVC = note.object;
        if ([presentingVC isKindOfClass:[UIViewController class]]) {
            [presentingVC presentDeviceIDRotator];
        }
    }];
}

+ (NSString *)getCurrentDeviceID {
    return [[DeviceIDRotator sharedInstance] getDeviceID];
}

+ (NSString *)rotateDeviceID {
    return [[DeviceIDRotator sharedInstance] rotateDeviceID];
}

+ (void)presentRotatorViewControllerFrom:(UIViewController *)viewController {
    DeviceIDRotatorViewController *rotatorVC = [[DeviceIDRotatorViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rotatorVC];
    [viewController presentViewController:navController animated:YES completion:nil];
}

@end
