//
//  AVCaptureDevice+Configure.h
//  Hey
//
//  Created by wang on 2017/5/30.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureDevice (Configure)

+ (instancetype)rs_defaultVideoDevice;
+ (instancetype)rs_defaultAudioDevice;

+ (instancetype)rs_currentVideoDevice;
+ (void)rs_setCurrentDevice:(AVCaptureDevice *)curDev;

- (instancetype _Nullable )rs_switchCameraToPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDeviceInput * _Nullable)rs_defaultDeviceInput;

- (void)rs_modifyConfigureCompleted:(void (^)(void))completed;
- (void)rs_focusOnPoint:(CGPoint)point isContinuousMode:(BOOL)bRet;
//
+ (void)rs_releaseAssociateObj;

@end

NS_ASSUME_NONNULL_END
