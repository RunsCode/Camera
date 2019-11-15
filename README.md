# RunsCamera
### A custom camera, the core function a little click to take pictures, long press the video

# From CocoaPods

```java
pod 'RunsCamera', '~> 1.0.3'
```

```swift
#import "ViewController.h"
#import "RunsCameraViewController.h"

@interface ViewController ()<RunsCameraControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    RunsCameraViewController *cameraViewController = [RunsCameraViewController new];
    cameraViewController.delegate = self;
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

#pragma mark -- RunsCameraControllerDelegate

- (void)cameraViewControllerDidDismissed:(UIViewController *)controller {
}

- (void)cameraViewControllerDidSelectedAlnbum:(UIViewController *)controller {
}

- (void)cameraViewController:(UIViewController *)controller captureStillImage:(UIImage *)image {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraViewController:(UIViewController *)controller captureVideoAsset:(RunsVideoAsset *)asset {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
```
