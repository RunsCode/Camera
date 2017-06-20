//
//  RunsCameraControllerDelegate.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RunsVideoAsset;

@protocol RunsCameraControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidDismissed:(UIViewController *)controller;
@required
- (void)cameraViewControllerDidSelectedAlnbum:(UIViewController *)controller;
- (void)cameraViewController:(UIViewController *)controller captureStillImage:(UIImage *)image;
- (void)cameraViewController:(UIViewController *)controller captureVideoAsset:(RunsVideoAsset *)asset;
@end
