//
//  RunsCameraKit.h
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#ifndef RunsCameraKit_h
#define RunsCameraKit_h
//
#import "RunsCameraManager.h"
#import "UIImage+Configure.h"
#import "AVCaptureDevice+Configure.h"
#import "AVCaptureSession+Configure.h"
//
#import "RunsCircleButtonView.h"
#import "RunsExpandButton.h"
#import "RunsCameraView.h"
#import "RunsCameraPreviewView.h"
//
#import "RunsCameraViewController.h"
#import "RunsPreviewViewController.h"


#define RCK_SCREEN_BOUNDS (UIScreen.mainScreen.bounds)
#define RCK_SCREEN_SIZE (UIScreen.mainScreen.bounds.size)
#define RCK_SCREEN_WIDTH (UIScreen.mainScreen.bounds.size.width)
#define RCK_SCREEN_HEIGHT (UIScreen.mainScreen.bounds.size.height)
#define RCKUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#ifdef DEBUG
#define RCKLog(format, ...) NSLog(@"[%d], %@: %@ %@", NSThread.isMainThread, self, NSStringFromSelector(_cmd), ([NSString stringWithFormat:format, ## __VA_ARGS__]));
#else
#define RCKLog(format, ...);
#endif

#ifdef DEBUG
#define RCKLogEX(format, ...) NSLog(@"[%d] %s %@", NSThread.isMainThread, __PRETTY_FUNCTION__, ([NSString stringWithFormat:format, ## __VA_ARGS__]));
#else
#define RCKLogEX(format, ...)
#endif


#endif /* RunsCameraKit_h */
