//
//  RunsCameraPreviewView.h
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RunsCameraPreviewViewDelegate.h"

@interface RunsCameraPreviewView : UIView
@property (nonatomic, weak) id<RunsCameraPreviewViewDelegate> delegate;
@end


@interface RunsVideoAsset : NSObject
@property (nonatomic, readonly) NSData *data;//视频原始数据
@property (nonatomic, readonly) UIImage *preview;//视频第一帧预览
@property (nonatomic, readonly) NSTimeInterval duration;//视频时长秒数
@property (nonatomic, readonly) AVAsset *asset;
- (instancetype)initWithData:(NSData *)video preview:(UIImage *)image duration:(NSTimeInterval)interval asset:(AVAsset *)playerItemAsset;
@end
