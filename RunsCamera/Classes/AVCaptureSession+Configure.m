//
//  AVCaptureSession+Configure.m
//  Hey
//
//  Created by wang on 2017/5/30.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "AVCaptureSession+Configure.h"
#import <objc/runtime.h>
#import "RunsCameraKit.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "AVCaptureDevice+Configure.h"

static const NSString * RunsDefaultDeviceSessionKey = @"RunsDefaultDeviceSessionKey";
static const NSString * RunsDefaultPreviewLayerKey  = @"RunsDefaultPreviewLayerKey";

@interface AVCaptureSession ()<AVCaptureFileOutputRecordingDelegate>

@end

@implementation AVCaptureSession (Configure)

+ (instancetype)rs_defaultSession {
    AVCaptureSession *session = (AVCaptureSession *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsDefaultDeviceSessionKey);
    if (session)  return session;
    session = [AVCaptureSession new];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultDeviceSessionKey, session, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return session;
}

- (void)rs_adaptivePresetPixelsWithCommit:(BOOL)needCommit {
    if (needCommit) {
        [self beginConfiguration];
    }
    
    AVCaptureDevicePosition curPosition = [AVCaptureDevice.rs_currentVideoDevice position];
    if (AVCaptureDevicePositionFront == curPosition) {
        if ([self canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [self setSessionPreset:AVCaptureSessionPreset1280x720];
            RCKLog(@"前置摄像头配置 720p")
        }else if ([self canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [self setSessionPreset:AVCaptureSessionPresetHigh];
            RCKLog(@"前置摄像头配置 预设高质量像素")
        }else{
            [self setSessionPreset:AVCaptureSessionPreset640x480];
            RCKLog(@"前置摄像头配置 480p")
        }
        if (needCommit) {
            [self commitConfiguration];
        }
        return;
    }
    
    if ([self canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [self setSessionPreset:AVCaptureSessionPreset1920x1080];
        RCKLog(@"后置摄像头配置 1080p")
    }else if ([self canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self setSessionPreset:AVCaptureSessionPreset1280x720];
        RCKLog(@"后置摄像头配置 720p")
    } else if ([self canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self setSessionPreset:AVCaptureSessionPresetHigh];
        RCKLog(@"后置摄像头配置 预设高质量像素")
    }else{
        [self setSessionPreset:AVCaptureSessionPreset640x480];
        RCKLog(@"后置摄像头配置 480p")
    }
    if (needCommit) {
        [self commitConfiguration];
    }
}

- (BOOL)rs_canSetSessionPreset:(NSString *)preset {
    BOOL bRet = NO;
    [self beginConfiguration];
    if ([self canSetSessionPreset:preset]) {
        [self setSessionPreset:preset];
        //
        bRet = YES;
    }
    [self commitConfiguration];
    return bRet;
}

- (AVCaptureVideoPreviewLayer *)rs_defaultPreviewLayer {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)objc_getAssociatedObject(self, &RunsDefaultPreviewLayerKey);
    if (layer) return layer;
    layer = [AVCaptureVideoPreviewLayer layerWithSession:self];
    layer.frame = UIScreen.mainScreen.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.doubleSided = NO;
    objc_setAssociatedObject(self, &RunsDefaultPreviewLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return layer;
}

- (void)rs_resume {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf.rs_defaultPreviewLayer.session.isRunning || weakSelf.rs_defaultPreviewLayer.session.isInterrupted) {
            return;
        }
        [weakSelf.rs_defaultPreviewLayer.session startRunning];
        RCKLog(@"previewLayer?.session.startRunning")
    });
}

- (void)rs_onSwitchCamera {
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count <= 1) {
        RCKLog(@"只有一个摄像头 无法进行切换");
        return;
    }
    CATransition *animation = [CATransition new];
    animation.duration = 0.05;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = @"fade";
    animation.subtype = kCATransitionFade;
    
    [self beginConfiguration];
    AVCaptureDevice *curVideoDevice = [AVCaptureDevice rs_currentVideoDevice];
    AVCaptureDevicePosition curPosition = [curVideoDevice position];
    AVCaptureDevicePosition newPosition = AVCaptureDevicePositionFront;
    if (AVCaptureDevicePositionFront == curPosition) {
        newPosition = AVCaptureDevicePositionBack;
    }
    curVideoDevice = [curVideoDevice rs_switchCameraToPosition:newPosition];
    [AVCaptureDevice rs_setCurrentDevice:curVideoDevice];
    [self rs_adaptivePresetPixelsWithCommit:NO];
    
    NSError *error = nil;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:curVideoDevice error:&error];
    if (error) {
        [self commitConfiguration];
        RCKLog(@"初始化 AVCaptureDeviceInput newDeviceInput 失败")
        return;
    }
    for (AVCaptureDeviceInput *oldInput in self.inputs) {
        if (AVCaptureDevice.rs_defaultAudioDevice.rs_defaultDeviceInput != oldInput) {
            [self removeInput:oldInput];
        }
    }
    if (![self canAddInput:newInput]) {
        [self commitConfiguration];
        RCKLog(@"加载 AVCaptureDeviceInput newDeviceInput 失败")
        return;
    }
    
    [self addInput:newInput];
    [self.rs_defaultPreviewLayer addAnimation:animation forKey:nil];
    [self commitConfiguration];
}

+ (void)rs_releaseAssociateObj {
    [AVCaptureSession.rs_defaultSession stopRunning];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultDeviceSessionKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(AVCaptureSession.rs_defaultSession, &RunsDefaultPreviewLayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
























