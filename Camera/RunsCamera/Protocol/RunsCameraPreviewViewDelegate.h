//
//  RunsCameraPreviewViewDelegate.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class RunsVideoAsset;
@protocol RunsCameraPreviewViewDelegate <NSObject>
- (void)previewDidCancel:(UIView *)preview;
- (void)preview:(UIView *)preview captureStillImage:(UIImage *)image;
- (void)preview:(UIView *)preview captureVideoAsset:(RunsVideoAsset *)asset;
@end

