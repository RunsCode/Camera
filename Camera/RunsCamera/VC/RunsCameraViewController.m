//
//  RunsCameraViewController.m
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsCameraViewController.h"
#import "RunsCameraKit.h"
#import "RunsCameraViewDelegate.h"
#import "RunsCameraPreviewViewDelegate.h"
#import "RunsCameraPreviewViewProtocol.h"

@interface RunsCameraViewController ()<RunsCameraViewDelegate, RunsCameraPreviewViewDelegate>

@end

@implementation RunsCameraViewController {
    RunsCameraView *runsCameraView;
    RunsCameraPreviewView<RunsCameraPreviewViewProtocol> *previewView;
}

- (void)dealloc {
    RCKLog(@"RunsCameraViewController Release");
    //
    [RunsCameraManager removeObserver];
    [RunsCameraManager releaseAllObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    runsCameraView = [[RunsCameraView alloc] initWithFrame:self.view.frame];
    runsCameraView.videoInterval = self.videoInterval;
    runsCameraView.delegate = self;
    [self.view addSubview:runsCameraView];
    //
    previewView = [[RunsCameraPreviewView<RunsCameraPreviewViewProtocol> alloc] initWithFrame:self.view.frame];
    previewView.hidden = YES;
    previewView.delegate = self;
    [self.view addSubview:previewView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark -- RunsCameraViewDelegate

- (void)cameraViewDidDismissed:(UIView *)cameraView {
    RCKLog(@"退出相机模式")
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewControllerDidDismissed:)]) {
        [_delegate cameraViewControllerDidDismissed:self];
    }
}

- (void)cameraViewDidSelectedAlnbum:(UIView *)cameraView {
    RCKLogEX(@"点击 选取相册")
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewControllerDidSelectedAlnbum:)]) {
        [_delegate cameraViewControllerDidSelectedAlnbum:self];
    }
}

- (void)cameraView:(UIView *)cameraView captureStillImage:(UIImage *)image {
    if (!image) {
        RCKLog(@"照片已损坏")
        return;
    }
    RCKLogEX(@"预览 照片")
    if (![previewView conformsToProtocol:@protocol(RunsCameraPreviewViewProtocol)]) {
        RCKLog(@" %@ Not implementation RunsCameraPreviewViewProtocol", previewView)
        return;
    }
    [previewView showMediaContentImage:image withType:Enum_StillImage];
    cameraView.hidden = YES;
    previewView.hidden = NO;
}

- (void)cameraView:(UIView *)cameraView captureVideoURL:(NSURL *)outputFileURL {
    
    if (outputFileURL.absoluteString.length <= 0) {
        RCKLog(@"视频已损坏")
        return;
    }
    
    RCKLogEX(@"预览 视频")
    if (![previewView conformsToProtocol:@protocol(RunsCameraPreviewViewProtocol)]) {
        RCKLog(@" %@ Not implementation RunsCameraPreviewViewProtocol", previewView)
        return;
    }
    cameraView.hidden = YES;
    [previewView showMediaContentVideo:outputFileURL withType:Enum_VideoURLPath];
    previewView.hidden = NO;
}

#pragma mark -- RunsCameraPreviewViewDelegate

- (void)previewDidCancel:(UIView *)preview {
    RCKLogEX(@"预览 返回继续拍照")
    if (![previewView conformsToProtocol:@protocol(RunsCameraPreviewViewProtocol)]) {
        RCKLog(@" %@ Not implementation RunsCameraPreviewViewProtocol", previewView)
        return;
    }
    [previewView clearContent:YES];
    previewView.hidden = YES;
    runsCameraView.hidden = NO;
}

- (void)preview:(UIView *)preview captureStillImage:(UIImage *)image {
    RCKLogEX(@"预览结束  回调照片")
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewController:captureStillImage:)]) {
        [_delegate cameraViewController:self captureStillImage:image];
    }
}

- (void)preview:(UIView *)preview captureVideoAsset:(RunsVideoAsset *)asset {
    RCKLogEX(@"预览结束  回调视频")
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewController:captureVideoAsset:)]) {
        [_delegate cameraViewController:self captureVideoAsset:asset];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
