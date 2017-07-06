//
//  RunsCameraManager.m
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsCameraManager.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "AVCaptureSession+Configure.h"
#import "RunsCameraKit.h"
#import "AVCaptureDevice+Configure.h"
#import "UIImage+Configure.h"

static const NSString * RunsDefaultMovieFileOutputKey       = @"RunsDefaultMovieFileOutputKey";
static const NSString * RunsDefaultStillImageOutputKey      = @"RunsDefaultStillImageOutputKey";
static const NSString * RunsCaptureVideoOutputCallbackKey   = @"RunsCaptureVideoOutputCallbackKey";

#define ALERTVIEW_TAG (0x23dede)

@interface RunsCameraManager ()<UIAlertViewDelegate>

@end

@implementation RunsCameraManager

+ (BOOL)checkAVAuthorizationStatus:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在“系统设置-隐私-照相”中开启App相机权限" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = ALERTVIEW_TAG;
        [alert show];
        return NO;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:handler];
        return NO;
    }
    if (status == ALAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkRecordPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在“系统设置-隐私-麦克风”中开启App麦克风权限" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = ALERTVIEW_TAG;
        [alert show];
        return NO;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:nil];
        return NO;
    }
    if (status == ALAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkPhotoLibrary {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在“系统设置-隐私-相册”中开启App相册权限" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = ALERTVIEW_TAG;
        [alert show];
        return NO;
    }
    if (status == ALAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (ALERTVIEW_TAG == alertView.tag ) {
        NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settings]) {
            if ([UIApplication.sharedApplication openURL:settings]) return;
            [UIApplication.sharedApplication openURL:settings options:@{} completionHandler:nil];
        }
    }
}

+ (AVCaptureMovieFileOutput *)movieFileOutput {
    AVCaptureMovieFileOutput *movieOutput = (AVCaptureMovieFileOutput *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsDefaultMovieFileOutputKey);
    if (movieOutput) {
        return movieOutput;
    }
    movieOutput = [AVCaptureMovieFileOutput new];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultMovieFileOutputKey, movieOutput, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return movieOutput;
}

+ (AVCaptureStillImageOutput *)stillImageOutput {
    AVCaptureStillImageOutput *imageOutput = (AVCaptureStillImageOutput *)objc_getAssociatedObject(UIApplication.sharedApplication, &RunsDefaultStillImageOutputKey);
    if (imageOutput) {
        return imageOutput;
    }
    imageOutput = [AVCaptureStillImageOutput new];
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultStillImageOutputKey, imageOutput, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return imageOutput;
}

+ (void)releaseAssociateObj {
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultMovieFileOutputKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(UIApplication.sharedApplication, &RunsDefaultStillImageOutputKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(AVCaptureSession.rs_defaultSession, &RunsCaptureVideoOutputCallbackKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)releaseAllObject {
    [RunsCameraManager releaseAssociateObj];
    [AVCaptureDevice rs_releaseAssociateObj];
    [AVCaptureSession rs_releaseAssociateObj];
}

+ (void)defaultVideoConfigurationWithCompleted:(void (^)(void))completed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureSession *session = [AVCaptureSession rs_defaultSession];
        [session beginConfiguration];
        //
        AVCaptureDevice *videoDevice = [AVCaptureDevice rs_defaultVideoDevice];
        AVCaptureDeviceInput *videoInput = [AVCaptureDevice.rs_defaultVideoDevice rs_defaultDeviceInput];
        if ([session canAddInput:videoInput]) {
            [session addInput:videoInput];
        }
        //
        AVCaptureDeviceInput *audioInput = [AVCaptureDevice.rs_defaultAudioDevice rs_defaultDeviceInput];
        if ([session canAddInput:audioInput]) {
            [session addInput:audioInput];
        }
        //
        AVCaptureMovieFileOutput *moviewFileOutput = [RunsCameraManager movieFileOutput];
        if ([session canAddOutput:moviewFileOutput]) {
            [session addOutput:moviewFileOutput];
        }
        //
        AVCaptureStillImageOutput *imageOutput = [RunsCameraManager stillImageOutput];
        if ([session canAddOutput:imageOutput]) {
            [session addOutput:imageOutput];
        }
        //
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [session setSessionPreset:AVCaptureSessionPreset1920x1080];
            RCKLogEX(@"配置 1080p");
        }else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [session setSessionPreset:AVCaptureSessionPreset1280x720];
            RCKLogEX(@"配置 720p");
        }else if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [session setSessionPreset:AVCaptureSessionPresetHigh];
        }else {
            [session setSessionPreset:AVCaptureSessionPreset640x480];
        }
        //
        AVCaptureConnection *connection = [moviewFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoStabilizationSupported) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
        //
        [session commitConfiguration];
        //
        __weak typeof(videoDevice) weakVideoDevide = videoDevice;
        [videoDevice rs_modifyConfigureCompleted:^{
            weakVideoDevide.videoZoomFactor = 1.0;
            [weakVideoDevide setSubjectAreaChangeMonitoringEnabled:YES];
            [weakVideoDevide rs_focusOnPoint:CGPointMake(RCK_SCREEN_WIDTH*0.5, RCK_SCREEN_HEIGHT*0.5) isContinuousMode:NO];
        }];
        if (!connection.isActive || !connection.isEnabled) {
            RCKLogEX(@"No active/enabled connections");
        }
        [session startRunning];
        
        AVCaptureDevice * dev = [AVCaptureDevice.rs_defaultVideoDevice rs_switchCameraToPosition:AVCaptureDevicePositionBack];
        if (!dev) {
            RCKLog(@"初始化后置摄像头错误!");
        }
        [AVCaptureDevice rs_setCurrentDevice:dev];

        if (completed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completed();
            });
        }
    });
}

+ (void)registeredObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionRuntimeErrorNotification object:AVCaptureSession.rs_defaultSession];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionErrorKey object:AVCaptureSession.rs_defaultSession];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionDidStartRunningNotification object:AVCaptureSession.rs_defaultSession];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionDidStopRunningNotification object:AVCaptureSession.rs_defaultSession];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionWasInterruptedNotification object:AVCaptureSession.rs_defaultSession];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleObserverEvent:) name:AVCaptureSessionInterruptionEndedNotification object:AVCaptureSession.rs_defaultSession];
}

+ (void)removeObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

+ (void)handleObserverEvent:(NSNotification *)noticaition {
    NSString *name = [noticaition name];
    
    if ([name isEqualToString:AVCaptureDeviceSubjectAreaDidChangeNotification]) {
        RCKLogEX(@"%@", AVCaptureDeviceSubjectAreaDidChangeNotification);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [AVCaptureDevice.rs_defaultVideoDevice rs_focusOnPoint:CGPointMake(RCK_SCREEN_WIDTH*0.5, RCK_SCREEN_HEIGHT*0.5) isContinuousMode:NO];
        });
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionRuntimeErrorNotification]) {
        RCKLogEX(@"%@  需要重启", AVCaptureSessionRuntimeErrorNotification);
        [self defaultVideoConfigurationWithCompleted:nil];
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionErrorKey]) {
        RCKLogEX(@"%@ 需要重启", AVCaptureSessionErrorKey);
        [self defaultVideoConfigurationWithCompleted:nil];
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionDidStartRunningNotification]) {
        RCKLogEX(@"%@", AVCaptureSessionDidStartRunningNotification);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [AVCaptureDevice.rs_defaultVideoDevice rs_focusOnPoint:CGPointMake(RCK_SCREEN_WIDTH*0.5, RCK_SCREEN_HEIGHT*0.5) isContinuousMode:NO];
        });
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionDidStopRunningNotification]) {
        RCKLogEX(@"%@", AVCaptureSessionDidStopRunningNotification);
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionWasInterruptedNotification]) {
        RCKLogEX(@"%@", AVCaptureSessionWasInterruptedNotification);
        return;
    }
    
    if ([name isEqualToString:AVCaptureSessionInterruptionEndedNotification]) {
        RCKLogEX(@"%@", AVCaptureSessionInterruptionEndedNotification);
        return;
    }
}

+ (void)captureStillImageCompleted:(void (^)(UIImage *stillImage))completed {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    if (!videoConnection || !videoConnection.isEnabled || !videoConnection.isActive) {
        [RunsCameraManager releaseAllObject];
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!imageDataSampleBuffer) {
            RCKLog(@"拍照失败")
            return;
        }
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *stillImage = [[UIImage imageWithData:data] rs_fixOrientation];
        
        if (AVCaptureDevicePositionFront == AVCaptureDevice.rs_currentVideoDevice.position) {
            UIImageOrientation flipImageOrientation = (stillImage.imageOrientation + 4) % 8;
            stillImage = [UIImage imageWithCGImage:stillImage.CGImage scale:stillImage.scale orientation:flipImageOrientation];
        }
        if (completed) {
            completed(stillImage);
        }
        [AVCaptureSession.rs_defaultSession rs_resume];
    }];
}


#pragma mark -- AVCaptureFileOutputRecordingDelegate {

+ (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    RCKLog(@"---- 开始录制 ---- \n%@", fileURL)
}

+ (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    RCKLog(@"---- 录制结束 ---- \n%@", outputFileURL)
    CaptureVideoOutputCallback callback = self.captureVideoOutputCallback;
    NSData *data = [NSData dataWithContentsOfURL:outputFileURL];
    if (!data || data.length <= 0 || error) {
        if (!error) {
            error = [NSError errorWithDomain:@"录制视频失败 输出为空" code:-1 userInfo:nil];
        }
        if (callback) {
            callback(nil, error);
        }
        RCKLog(@"录制视频失败 输出为空")
        return;
    }
    RCKLog(@"录制视频成功 回调输出给预览层")
    if (callback) {
        callback(outputFileURL, nil);
    }
}

+ (void)startCaptureVideoWithCallback:(void(^)(void))callback {
    if (callback) {
        callback();
    }

    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"input.mov"];
    NSURL *tempVideoURL = [NSURL fileURLWithPath:tempFilePath];
    if ([NSFileManager.defaultManager fileExistsAtPath:tempFilePath]) {
        NSError *error = nil;
        [NSFileManager.defaultManager removeItemAtURL:tempVideoURL error:&error];
        if (error) {
            RCKLog(@"FileManager.default.removeItem fail at path : %@, 无法录制视频",tempFilePath)
            return;
        }
    }
    AVCaptureSession *session = [AVCaptureSession rs_defaultSession];
    if (!session.isRunning || session.isInterrupted ) {
       [session startRunning];
        RCKLog(@"session 会话异常 需要重新开启 开启录制视频输出失败")
        return;
    }
    AVCaptureMovieFileOutput *movieFileOutput = self.movieFileOutput;
    if (movieFileOutput.isRecording) {
        [movieFileOutput stopRecording];
    }
    AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection.isActive || !connection.isEnabled) {
        RCKLog(@"No active/enabled connections")
        [session startRunning];
        [RunsCameraManager releaseAllObject];
        return;
    }
    
    [movieFileOutput startRecordingToOutputFileURL:tempVideoURL recordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)self];
    RCKLog(@"开启录制录制视频输出")
}

+ (void)stopCaptureVideoWithCallback:(void(^)(void))callback {
    if (callback) {
        callback();
    }
    [self.movieFileOutput stopRecording];
    CaptureVideoOutputCallback outputCallback = self.captureVideoOutputCallback;
    outputCallback = nil;
    RCKLog(@"结束录制录制视频输出")
}

+ (void)captureVideoFinishedCallback:(CaptureVideoOutputCallback)completed {
    if (!completed) return;
    objc_setAssociatedObject(AVCaptureSession.rs_defaultSession, &RunsCaptureVideoOutputCallbackKey, completed, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (CaptureVideoOutputCallback)captureVideoOutputCallback {
    return objc_getAssociatedObject(AVCaptureSession.rs_defaultSession, &RunsCaptureVideoOutputCallbackKey);
}

+ (void)compressVideoWithUrl:(NSURL *)videoUrl completed:(void (^) (NSData * _Nullable data))callback {
    RCKLog(@"开始压缩,压缩前大小 %f MB",[NSData dataWithContentsOfURL:videoUrl].length/1024.00/1024.00);
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    NSURL * outputUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"outPut.mov"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"outPut.mov"]]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputUrl error:nil];
    }
    exportSession.outputURL = outputUrl;
    exportSession.shouldOptimizeForNetworkUse = true;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                NSData * data = [NSData dataWithContentsOfURL:outputUrl];
                RCKLog(@"压缩完毕,压缩后大小: %f MB",data.length/1024.00/1024.00);
                if (callback) {
                    callback(data);
                }
            }else{
#ifdef DEBUG
                RCKLog(@"当前压缩进度:%f",exportSession.progress);
                NSError *exportError = exportSession.error;
                RCKLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
#endif
                if (callback) {
                    callback(nil);
                }
            }
        });
    }];
}

@end




























