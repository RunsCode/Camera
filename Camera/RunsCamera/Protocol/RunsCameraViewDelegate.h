//
//  RunsCameraViewDelegate.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunsCameraViewDelegate <NSObject>
- (void)cameraViewDidDismissed:(UIView *)cameraView;
- (void)cameraViewDidSelectedAlnbum:(UIView *)cameraView;
- (void)cameraView:(UIView *)cameraView captureStillImage:(UIImage *)image;
- (void)cameraView:(UIView *)cameraView captureVideoURL:(NSURL *)outputFileURL;
@end
