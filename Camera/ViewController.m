//
//  ViewController.m
//  Camera
//
//  Created by wang on 2017/6/16.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "ViewController.h"
#import "RunsCameraViewController.h"

@interface ViewController ()<RunsCameraControllerDelegate>

@end

@implementation ViewController {
}

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
