//
//  DeviceIDRotatorUI.m
//  Optional UI component for Device ID Rotator
//  Can be compiled separately or integrated into the dylib
//

#import <UIKit/UIKit.h>
#import "DeviceIDRotator.h"

@interface DeviceIDRotatorViewController : UIViewController
@property (nonatomic, strong) UILabel *deviceIDLabel;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *copyButton;
@end

@implementation DeviceIDRotatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Device ID Manager";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self
        action:@selector(dismiss)];
    
    [self setupUI];
    [self updateDeviceID];
}

- (void)setupUI {
    // Device ID Label
    self.deviceIDLabel = [[UILabel alloc] init];
    self.deviceIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceIDLabel.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular];
    self.deviceIDLabel.textColor = [UIColor labelColor];
    self.deviceIDLabel.numberOfLines = 0;
    self.deviceIDLabel.textAlignment = NSTextAlignmentCenter;
    self.deviceIDLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.deviceIDLabel.layer.cornerRadius = 8;
    self.deviceIDLabel.clipsToBounds = YES;
    [self.view addSubview:self.deviceIDLabel];
    
    // Copy Button
    self.copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.copyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.copyButton setTitle:@"Copy Device ID" forState:UIControlStateNormal];
    self.copyButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.copyButton.backgroundColor = [UIColor systemBlueColor];
    [self.copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.copyButton.layer.cornerRadius = 8;
    [self.copyButton addTarget:self action:@selector(copyDeviceID) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.copyButton];
    
    // Rotate Button
    self.rotateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rotateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rotateButton setTitle:@"🔄 Rotate Device ID" forState:UIControlStateNormal];
    self.rotateButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.rotateButton.backgroundColor = [UIColor systemOrangeColor];
    [self.rotateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rotateButton.layer.cornerRadius = 12;
    [self.rotateButton addTarget:self action:@selector(rotateDeviceID) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateButton];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.deviceIDLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [self.deviceIDLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.deviceIDLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.deviceIDLabel.heightAnchor constraintGreaterThanOrEqualToConstant:80],
        
        [self.copyButton.topAnchor constraintEqualToAnchor:self.deviceIDLabel.bottomAnchor constant:20],
        [self.copyButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.copyButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.copyButton.heightAnchor constraintEqualToConstant:50],
        
        [self.rotateButton.topAnchor constraintEqualToAnchor:self.copyButton.bottomAnchor constant:30],
        [self.rotateButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.rotateButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.rotateButton.heightAnchor constraintEqualToConstant:60]
    ]];
}

- (void)updateDeviceID {
    const char *deviceID = getCurrentDeviceID();
    NSString *deviceIDString = [NSString stringWithUTF8String:deviceID];
    self.deviceIDLabel.text = [NSString stringWithFormat:@"Current Device ID:\n%@", deviceIDString];
}

- (void)rotateDeviceID {
    rotateDeviceID();
    [self updateDeviceID];
    
    // Animate button
    [UIView animateWithDuration:0.2 animations:^{
        self.rotateButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.rotateButton.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)copyDeviceID {
    const char *deviceID = getCurrentDeviceID();
    NSString *deviceIDString = [NSString stringWithUTF8String:deviceID];
    [UIPasteboard generalPasteboard].string = deviceIDString;
    
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Copied!" 
        message:@"Device ID copied to clipboard" 
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

// Function to present the UI (can be called from anywhere)
void presentDeviceIDRotatorUI(UIViewController *presentingViewController) {
    DeviceIDRotatorViewController *vc = [[DeviceIDRotatorViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [presentingViewController presentViewController:nav animated:YES completion:nil];
}
