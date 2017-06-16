//
//  RunsCameraManager.h
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^CaptureVideoOutputCallback)(NSURL * _Nullable outputFileURL, NSError *_Nullable error);

@interface RunsCameraManager : NSObject

#pragma mark -- Authorized

+ (BOOL)checkAVAuthorizationStatus:(void (^)(BOOL granted))handle;
+ (BOOL)checkRecordPermission;
+ (BOOL)checkPhotoLibrary;

#pragma hardWare And Session initialized

+ (AVCaptureMovieFileOutput *)movieFileOutput;
+ (AVCaptureStillImageOutput *)stillImageOutput;
+ (void)releaseAssociateObj;
+ (void)releaseAllObject;

+ (void)defaultVideoConfigurationWithCompleted:( void (^ _Nullable ) (void)) completed;

+ (void)registeredObserver;
+ (void)removeObserver;

+ (void)captureStillImageCompleted:(void (^) (UIImage *stillImage))completed;

+ (void)startCaptureVideoWithCallback:(void(^ _Nullable)(void))callback;
+ (void)stopCaptureVideoWithCallback:( void(^ _Nullable )(void))callback;
+ (void)captureVideoFinishedCallback:(CaptureVideoOutputCallback)completed;
+ (void)compressVideoWithUrl:(NSURL *)videoUrl completed:(void (^) (NSData * _Nullable data))callback;
@end

NS_ASSUME_NONNULL_END
