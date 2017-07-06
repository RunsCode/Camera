//
//  AVCaptureDevice+Configure.m
//  Hey
//
//  Created by wang on 2017/5/30.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "AVCaptureDevice+Configure.h"
#import <objc/runtime.h>
#import "RunsCameraKit.h"

static const NSString * RunsDefaultVideoDeviceKey = @"RunsDefaultVideoDeviceKey";
static const NSString * RunsCurrentVideoDeviceKey = @"RunsCurrentVideoDeviceKey";
static const NSString * RunsDefaultAudioDeviceKey = @"RunsDefaultAudioDeviceKey";
static const NSString * RunsDefaultDeviceInputKey = @"RunsDefaultDeviceInputKey";

@implementation AVCaptureDevice (Configure)

+ (instancetype)rs_defaultVideoDevice {
    AVCaptureDevice *videoDev = (AVCaptureDevice *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsDefaultVideoDeviceKey);
    if (videoDev) return videoDev;
    videoDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultVideoDeviceKey, videoDev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    [videoDev testKVO];

    return videoDev;
}

-(void)testKVO{
    [self addObserver:self forKeyPath:@"subjectAreaChangeMonitoringEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"subjectAreaChangeMonitoringEnabled"]) {
        RCKLog(@"Name is changed! new = %@",[change valueForKey:NSKeyValueChangeNewKey]);
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (instancetype)rs_defaultAudioDevice {
    AVCaptureDevice *audioDev = (AVCaptureDevice *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsDefaultAudioDeviceKey);
    if (audioDev) return audioDev;
    audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultAudioDeviceKey, audioDev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return audioDev;
}

+ (instancetype)rs_currentVideoDevice {
    AVCaptureDevice *videoDev = (AVCaptureDevice *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsCurrentVideoDeviceKey);
    if (videoDev) {
        return videoDev;
    }
    return [self rs_defaultVideoDevice];
}

+ (void)rs_setCurrentDevice:(AVCaptureDevice *)curDev {
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsCurrentVideoDeviceKey, curDev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (instancetype)rs_switchCameraToPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count <= 1) return nil;
    for (AVCaptureDevice *dev in devices) {
        if (position == dev.position) {
            return dev;
        }
    }
    return nil;
}

- (AVCaptureDeviceInput *)rs_defaultDeviceInput {
    AVCaptureDeviceInput *input = (AVCaptureDeviceInput *)objc_getAssociatedObject(self, &RunsDefaultDeviceInputKey);
    if (input)  return input;
    
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:self error:&error];
    if (error) {
#ifdef DEBUG
        NSString *mediaType = [self valueForKeyPath:@"mediaType"];
        RCKLog(@"获取%@ DeviceInput 失败 error: %@",mediaType, error);
#endif
        return nil;
    }
    objc_setAssociatedObject(self, &RunsDefaultDeviceInputKey, input, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return input;
}

- (void)rs_modifyConfigureCompleted:(void (^)(void))completed {
    if (!completed) {
        RCKLog(@"completed 回调为空 修改设备配置失败");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [weakSelf lockForConfiguration:&error];
        if (error) {
            RCKLogEX(@"锁定设备失败，修改配置失败")
            return;
        }
        completed();
        [weakSelf unlockForConfiguration];
    });

}

- (void)rs_focusOnPoint:(CGPoint)point isContinuousMode:(BOOL)bRet {
    AVCaptureFocusMode focusMode = bRet ? AVCaptureFocusModeContinuousAutoFocus : AVCaptureFocusModeAutoFocus;
    AVCaptureExposureMode exposurMode = bRet ? AVCaptureExposureModeContinuousAutoExposure : AVCaptureExposureModeAutoExpose;
    AVCaptureWhiteBalanceMode whiteBalanceMode = bRet ? AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance : AVCaptureWhiteBalanceModeAutoWhiteBalance;
    CGPoint focus = CGPointMake(point.y/RCK_SCREEN_HEIGHT, 1 - point.x/RCK_SCREEN_WIDTH);
    [self rs_modifyConfigureCompleted:^{
        if ([AVCaptureDevice.rs_defaultVideoDevice isFocusModeSupported:focusMode]) {
            [AVCaptureDevice.rs_defaultVideoDevice setFocusPointOfInterest:focus];
            [AVCaptureDevice.rs_defaultVideoDevice setFocusMode:focusMode];
        }
        if ([AVCaptureDevice.rs_defaultVideoDevice isExposureModeSupported:exposurMode]) {
            [AVCaptureDevice.rs_defaultVideoDevice setExposurePointOfInterest:focus];
            [AVCaptureDevice.rs_defaultVideoDevice setExposureMode:exposurMode];
        }
        if ([AVCaptureDevice.rs_defaultVideoDevice isWhiteBalanceModeSupported:whiteBalanceMode]) {
            [AVCaptureDevice.rs_defaultVideoDevice setWhiteBalanceMode:whiteBalanceMode];
        }
        [AVCaptureDevice.rs_defaultVideoDevice setSubjectAreaChangeMonitoringEnabled:!bRet];
    }];
    RCKLog(@"单点聚焦 x : %f, y : %f", focus.x, focus.y);
}

+ (void)rs_releaseAssociateObj {
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultVideoDeviceKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultAudioDeviceKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsCurrentVideoDeviceKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(AVCaptureDevice.rs_defaultVideoDevice, &RunsDefaultDeviceInputKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(AVCaptureDevice.rs_defaultAudioDevice, &RunsDefaultDeviceInputKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end















