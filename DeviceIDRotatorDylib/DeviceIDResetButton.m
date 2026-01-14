//
//  DeviceIDResetButton.m
//  Button component to reset device ID in Swiggy app
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSString *const kCustomDeviceIDKey = @"com.swiggy.customDeviceID";

@interface DeviceIDManager : NSObject
+ (NSString *)getCurrentDeviceID;
+ (NSString *)rotateDeviceID;
+ (void)showResetAlert;
@end

@implementation DeviceIDManager

+ (NSString *)getCurrentDeviceID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedID = [defaults stringForKey:kCustomDeviceIDKey];
    
    if (!storedID) {
        storedID = [[NSUUID UUID] UUIDString];
        [defaults setObject:storedID forKey:kCustomDeviceIDKey];
        [defaults synchronize];
    }
    
    return storedID;
}

+ (NSString *)rotateDeviceID {
    NSString *newID = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:newID forKey:kCustomDeviceIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return newID;
}

+ (void)showResetAlert {
    UIViewController *topVC = [self topViewController];
    if (!topVC) return;
    
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Reset Device ID" 
        message:@"This will generate a new device ID. The app will need to restart for changes to take full effect." 
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *resetAction = [UIAlertAction 
        actionWithTitle:@"Reset" 
        style:UIAlertActionStyleDestructive 
        handler:^(UIAlertAction *action) {
            NSString *newID = [DeviceIDManager rotateDeviceID];
            
            UIAlertController *successAlert = [UIAlertController 
                alertControllerWithTitle:@"Device ID Reset" 
                message:[NSString stringWithFormat:@"New Device ID:\n%@\n\nPlease restart the app.", newID] 
                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction 
                actionWithTitle:@"OK" 
                style:UIAlertActionStyleDefault 
                handler:nil];
            
            [successAlert addAction:okAction];
            [topVC presentViewController:successAlert animated:YES completion:nil];
        }];
    
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel 
        handler:nil];
    
    [alert addAction:resetAction];
    [alert addAction:cancelAction];
    
    [topVC presentViewController:alert animated:YES completion:nil];
}

+ (UIViewController *)topViewController {
    UIWindow *keyWindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    UIViewController *rootVC = keyWindow.rootViewController;
    return [self topViewControllerFrom:rootVC];
}

+ (UIViewController *)topViewControllerFrom:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self topViewControllerFrom:[(UINavigationController *)viewController topViewController]];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self topViewControllerFrom:[(UITabBarController *)viewController selectedViewController]];
    }
    
    if (viewController.presentedViewController) {
        return [self topViewControllerFrom:viewController.presentedViewController];
    }
    
    return viewController;
}

@end

// Add button to settings view controller
__attribute__((constructor))
static void addResetButton() {
    @autoreleasepool {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [DeviceIDManager addResetButtonToSettings];
        });
    }
}

@implementation DeviceIDManager (UI)

+ (void)addResetButtonToSettings {
    // Try to find settings/account view controller
    UIViewController *topVC = [self topViewController];
    
    if (!topVC) return;
    
    // Look for common settings view patterns
    [self addButtonToViewController:topVC];
    
    // Also try to find table view controllers (common for settings)
    [self findAndModifyTableViews:topVC];
}

+ (void)addButtonToViewController:(UIViewController *)vc {
    if (!vc.view) return;
    
    // Check if button already exists
    for (UIView *subview in vc.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && 
            [(UIButton *)subview.titleLabel.text containsString:@"Reset Device"]) {
            return; // Button already exists
        }
    }
    
    // Create floating button
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.backgroundColor = [UIColor systemOrangeColor];
    [resetButton setTitle:@"🔄 Reset Device ID" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    resetButton.layer.cornerRadius = 25;
    resetButton.layer.shadowColor = [UIColor blackColor].CGColor;
    resetButton.layer.shadowOffset = CGSizeMake(0, 2);
    resetButton.layer.shadowOpacity = 0.3;
    resetButton.layer.shadowRadius = 4;
    
    resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [vc.view addSubview:resetButton];
    
    // Position button (bottom right corner)
    [NSLayoutConstraint activateConstraints:@[
        [resetButton.widthAnchor constraintEqualToConstant:180],
        [resetButton.heightAnchor constraintEqualToConstant:50],
        [resetButton.trailingAnchor constraintEqualToAnchor:vc.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [resetButton.bottomAnchor constraintEqualToAnchor:vc.view.safeAreaLayoutGuide.bottomAnchor constant:-100]
    ]];
    
    [resetButton addTarget:self action:@selector(showResetAlert) forControlEvents:UIControlEventTouchUpInside];
    
    // Bring to front
    [vc.view bringSubviewToFront:resetButton];
}

+ (void)findAndModifyTableViews:(UIViewController *)vc {
    if ([vc.view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)vc.view;
        [self addButtonToTableHeader:tableView];
    }
    
    // Recursively check subviews
    for (UIView *subview in vc.view.subviews) {
        if ([subview isKindOfClass:[UITableView class]]) {
            [self addButtonToTableHeader:(UITableView *)subview];
        }
    }
    
    // Check child view controllers
    for (UIViewController *childVC in vc.childViewControllers) {
        [self findAndModifyTableViews:childVC];
    }
}

+ (void)addButtonToTableHeader:(UITableView *)tableView {
    if (!tableView) return;
    
    // Create header view with button
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.backgroundColor = [UIColor systemOrangeColor];
    [resetButton setTitle:@"🔄 Reset Device ID" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    resetButton.layer.cornerRadius = 8;
    resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [headerView addSubview:resetButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [resetButton.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [resetButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
        [resetButton.widthAnchor constraintEqualToConstant:200],
        [resetButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    [resetButton addTarget:self action:@selector(showResetAlert) forControlEvents:UIControlEventTouchUpInside];
    
    tableView.tableHeaderView = headerView;
}

@end
