//
//  AVCaptureSession+Configure.h
//  Hey
//
//  Created by wang on 2017/5/30.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureSession (Configure)
+ (instancetype)rs_defaultSession;
- (void)rs_adaptivePresetPixelsWithCommit:(BOOL)needCommit;
- (BOOL)rs_canSetSessionPreset:(NSString *)preset;
- (AVCaptureVideoPreviewLayer *)rs_defaultPreviewLayer;
- (void)rs_resume;
//
- (void)rs_onSwitchCamera;
//
+ (void)rs_releaseAssociateObj;

@end
NS_ASSUME_NONNULL_END
