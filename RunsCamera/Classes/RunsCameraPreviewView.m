//
//  RunsCameraPreviewView.m
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsCameraPreviewView.h"
#import "RunsCameraPreviewViewProtocol.h"
#import "RunsCameraKit.h"
#import "UIView+Toast.h"
#import "UIImage+Configure.h"
#import "RunsExpandButton.h"
#import "RunsCameraManager.h"

@interface RunsCameraPreviewView ()<RunsCameraPreviewViewProtocol>

@end

@implementation RunsCameraPreviewView {
    MediaContentType contentType;
    UIImageView *stillImageView;
    //
    NSURL *videoURLPath;
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
}

- (void)dealloc {
//    [self hideLoadingActivity];
    RCKLog(@"RunsCameraPreviewView Release")
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.stillImageView];
        [self addSubview:self.backButton];
        [self addSubview:self.confirmButton];
    }
    return self;
}

#pragma mark -- RunsCameraPreviewViewProtocol

- (void)showMediaContentImage:(UIImage *)image withType:(MediaContentType)type {
    contentType = type;
    RCKLog(@"预览图片");
    self.stillImageView.hidden = NO;
    playerLayer.hidden = YES;
    [self.stillImageView setImage:image];
}

- (void)showMediaContentVideo:(NSURL *)URLPath withType:(MediaContentType)type {
    contentType = type;
    videoURLPath = URLPath;
    //
    self.stillImageView.hidden = YES;
    //
    player = [AVPlayer playerWithURL:URLPath];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.frame;
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:playerLayer];
    [self.layer insertSublayer:playerLayer atIndex:0];
    //
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onPlaybackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [player play];
    });
    
    RCKLog(@"预览视频 outputURL: %@",URLPath);
}

- (void)onPlaybackFinished {
    [player seekToTime:CMTimeMake(0, 1)];
    [player play];
}

- (void)clearContent:(BOOL)needClear {
    if (!needClear) {
        return;
    }
    self.stillImageView.image = nil;
    if (player) {
        [player pause];
        player = nil;
        [playerLayer removeFromSuperlayer];
        playerLayer = nil;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onBackToCamera {
    if (_delegate && [_delegate respondsToSelector:@selector(previewDidCancel:)]) {
        [_delegate previewDidCancel:self];
        [self clearContent:YES];
    }
}

- (void)onConfirmContent {
    if (!_delegate) {
        RCKLog(@"代理回调为空， 无法返回所选的照片或者视频")
        return;
    }
    if (Enum_StillImage == contentType && stillImageView.image) {
        if (![_delegate respondsToSelector:@selector(preview:captureStillImage:)]) {
            RCKLog(@"回调代理类 并未实现 preview:captureStillImage:")
            return;
        }
        [_delegate preview:self captureStillImage:stillImageView.image];
        [self clearContent:YES];
        return;
    }
    
    if (Enum_VideoURLPath == contentType && videoURLPath) {
        if (![_delegate respondsToSelector:@selector(preview:captureVideoAsset:)]) {
            RCKLog(@"回调代理类 并未实现 preview:captureVideoURL:")
            return;
        }
        UIView *delegateView = [UIApplication.sharedApplication.delegate window];
        [delegateView makeLoadingActivity:@"准备中..."];
        UIImage *frame = [UIImage rs_fetchVideoPreViewImageWithUrl:videoURLPath];
        [RunsCameraManager compressVideoWithUrl:videoURLPath completed:^(NSData * _Nullable data) {
            [delegateView hideLoadingActivity];
            if (!data) {
                RCKLogEX(@"压缩失败");
                return;
            }
            [delegateView makeToast:@"压缩成功" duration:1.0 position:CSToastPositionCenter];
            NSTimeInterval duration = player.currentItem.duration.value / player.currentItem.duration.timescale;
            AVAsset *asset = player.currentItem.asset;
            RunsVideoAsset *videoAsset = [[RunsVideoAsset alloc] initWithData:data preview:frame duration:duration asset:asset];
            [_delegate preview:self captureVideoAsset:videoAsset];
            //
            [self clearContent:YES];
        }];
    }
}

- (UIImageView *)stillImageView {
    if (stillImageView) return stillImageView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.hidden = YES;
    stillImageView = imageView;
    return stillImageView;
}

- (RunsExpandButton *)backButton {
    RunsExpandButton *button = [RunsExpandButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, RCK_SCREEN_HEIGHT - 65 - 26, 65, 65);
    [button setImage:[UIImage imageNamed:@"rs_camera_preview_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBackToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (RunsExpandButton *)confirmButton {
    RunsExpandButton *button = [RunsExpandButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(RCK_SCREEN_WIDTH - 65 - 50, RCK_SCREEN_HEIGHT - 65 - 26, 65, 65);
    [button setImage:[UIImage imageNamed:@"rs_camera_preview_finished"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onConfirmContent) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}
@end

@implementation RunsVideoAsset

- (instancetype)initWithData:(NSData *)video preview:(UIImage *)image duration:(NSTimeInterval)interval asset:(AVAsset *)playerItemAsset {
    self = [super init];
    if (self) {
        _data = video;
        _preview = image;
        _duration = interval;
        _asset = playerItemAsset;
    }
    return self;
}

@end
