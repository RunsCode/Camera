//
//  RunsCameraView.m
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsCameraView.h"
#import "RunsCameraKit.h"
#import "RunsCircleButtonViewDelegate.h"
#import "RunsExpandButton.h"
#import "RunsCameraManager.h"
#import "RunsCircleButtonView.h"
#import "AVCaptureSession+Configure.h"
#import "AVCaptureDevice+Configure.h"
#define SHADOW_IMAGE_HEIGHT (140)

@interface RunsCameraView ()<RunsCircleButtonViewDelegate>

@end

@implementation RunsCameraView {
    UIView *focusView;
    UILabel *promptPanelLabel;
    RunsExpandButton *switchCameraButton;
    RunsExpandButton *selectedAlbumButton;
    RunsExpandButton *cameraCancelButton;
}

- (void)dealloc {
    RCKLog(@"RunsCameraView Release");
    [RunsCameraManager removeObserver];
    [RunsCameraManager releaseAllObject];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewMember];
        BOOL bRet = [RunsCameraManager checkAVAuthorizationStatus:^(BOOL granted) {
            if (granted) {
                [self initDevice];
            }
        }];
        if (bRet) {
            [self initDevice];
        }
    }
    return self;
}

- (void)initViewMember {
    self.alpha = 0.3;
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureSession.rs_defaultSession rs_defaultPreviewLayer];
    previewLayer.hidden = NO;
    [self.layer addSublayer:previewLayer];
    [self.layer insertSublayer:previewLayer atIndex:0];
    //
    [self addSubview:self.topShadowImageView];
    [self addSubview:self.bottomShadowImageView];
    [self addSubview:self.switchCameraButton];
    [self addSubview:self.selectedAlbumButton];
    [self addSubview:self.cameraCancelButton];
    [self addSubview:self.promptPanelLabel];
    [self addSubview:self.circleButtonView];
    [self showAssistComponet:YES];
}

- (void)initDevice {
    [RunsCameraManager defaultVideoConfigurationWithCompleted:^{
        [RunsCameraManager registeredObserver];
        
        [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.alpha = 1.0;
        }];
    }];
}

- (void)showAssistComponet:(BOOL)bRet {
    promptPanelLabel.hidden = !bRet;
    switchCameraButton.hidden = !bRet;
    selectedAlbumButton.hidden = !bRet;
    cameraCancelButton.hidden = !bRet;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self showAssistComponet:!hidden];
}
#pragma mark -- 点击事件回调

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [event.allTouches anyObject];
    CGPoint point = [touch locationInView:self];
    if (![self viewComponentContainPoint:point]) return;
    [AVCaptureDevice.rs_defaultVideoDevice rs_focusOnPoint:point isContinuousMode:NO];
    [self showFocusAnimationWithPoint:point];
}

- (BOOL)viewComponentContainPoint:(CGPoint)point {
    return YES;
}

- (void)showFocusAnimationWithPoint:(CGPoint)point {
    self.focusView.center = point;
    self.focusView.hidden = NO;
    self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    
    [UIView animateWithDuration:0.3 animations:^{
        focusView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        focusView.layer.borderColor = UIColor.greenColor.CGColor;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
            focusView.layer.borderColor = [UIColor.greenColor colorWithAlphaComponent:0.5].CGColor;
        } completion:^(BOOL finished) {
            focusView.transform = CGAffineTransformIdentity;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                focusView.hidden = YES;
            });
        }];
    }];
}


- (void)onSelectedAlbum {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewDidSelectedAlnbum:)]) {
        [_delegate cameraViewDidSelectedAlnbum:self];
    }
}

- (void)onCameraCancel {
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewDidDismissed:)]) {
        [_delegate cameraViewDidDismissed:self];
    }
}

#pragma mark -- RunsCircleButtonViewDelegate 

- (void)buttonView:(UIView *)button didClickTap:(UITapGestureRecognizer *)tapGes {
    [RunsCameraManager captureStillImageCompleted:^(UIImage * _Nonnull stillImage) {
        if (!stillImage) {
            RCKLogEX(@"拍照后转换图层失败得到的图片为空")
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(cameraView:captureStillImage:)]) {
            [_delegate cameraView:self captureStillImage:stillImage];
        }
    }];
}

- (void)buttonView:(UIView *)button didLongTapBegan:(UITapGestureRecognizer *)tapGes {
    [self showAssistComponet:NO];
    [RunsCameraManager startCaptureVideoWithCallback:nil];
    [RunsCameraManager captureVideoFinishedCallback:^(NSURL * _Nullable outputFileURL, NSError * _Nullable error) {
        if (!outputFileURL || error) {
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(cameraView:captureVideoURL:)]) {
            [_delegate cameraView:self captureVideoURL:outputFileURL];
        }
    }];
}

- (void)buttonView:(UIView *)button didLongTapEnded:(UITapGestureRecognizer *)tapGes {
    [RunsCameraManager stopCaptureVideoWithCallback:nil];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showAssistComponet:YES];
    });
}

#pragma mark -- init UI
- (UIImageView *)topShadowImageView {
    UIImageView *topShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, RCK_SCREEN_WIDTH, SHADOW_IMAGE_HEIGHT)];
    topShadowImageView.image = [UIImage imageNamed:@"rs_camera_view_top_shadow"];
    return topShadowImageView;
}

- (UIImageView *)bottomShadowImageView {
    UIImageView *bottomShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, RCK_SCREEN_HEIGHT - SHADOW_IMAGE_HEIGHT, RCK_SCREEN_WIDTH, SHADOW_IMAGE_HEIGHT)];
    bottomShadowImageView.image = [UIImage imageNamed:@"rs_camera_view_bottom_shadow"];
    return bottomShadowImageView;
}

- (UIView *)focusView {
    if (focusView)  return focusView;
    //
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    view.layer.borderWidth = 0.6;
    view.layer.borderColor = [UIColor.greenColor colorWithAlphaComponent:0.2].CGColor;
    view.backgroundColor = UIColor.clearColor;
    view.userInteractionEnabled = NO;
    view.hidden = YES;
    [self addSubview:view];
    focusView = view;
    return focusView;
}

- (RunsExpandButton *)switchCameraButton {
    if (switchCameraButton) return switchCameraButton;
    RunsExpandButton *button = [RunsExpandButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(RCK_SCREEN_WIDTH - 54, 40, 24, 20);
    button.expandPoint = CGPointMake(40, 47);
    [button setImage:[UIImage imageNamed:@"rs_switch_camera"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"rs_switch_camera"] forState:UIControlStateHighlighted];
    [button addTarget:AVCaptureSession.rs_defaultSession action:@selector(rs_onSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
    switchCameraButton = button;
    return switchCameraButton;
}

- (RunsExpandButton *)selectedAlbumButton {
    if (selectedAlbumButton) return selectedAlbumButton;
    RunsExpandButton *button = [RunsExpandButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(RCK_SCREEN_WIDTH - 64, RCK_SCREEN_HEIGHT - 68, 24, 21);
    button.expandPoint = CGPointMake(30, 40);
    [button setImage:[UIImage imageNamed:@"rs_camera_photo_album"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"rs_camera_photo_album"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onSelectedAlbum) forControlEvents:UIControlEventTouchUpInside];
    selectedAlbumButton = button;
    return selectedAlbumButton;
}

- (RunsExpandButton *)cameraCancelButton {
    if (cameraCancelButton) return cameraCancelButton;
    RunsExpandButton *button = [RunsExpandButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(41, RCK_SCREEN_HEIGHT - 66, 22, 12);
    button.expandPoint = CGPointMake(30, 40);
    [button setImage:[UIImage imageNamed:@"rs_camera_cancel"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"rs_camera_cancel"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onCameraCancel) forControlEvents:UIControlEventTouchUpInside];
    cameraCancelButton = button;
    return cameraCancelButton;
}

- (UILabel *)promptPanelLabel {
    if (promptPanelLabel) return promptPanelLabel;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, RCK_SCREEN_HEIGHT - 135, RCK_SCREEN_WIDTH, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = RCKUIColorFromRGB(0xd8d8d8);
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"轻触拍照，按住摄像";
    promptPanelLabel = label;
    return promptPanelLabel;
}

- (RunsCircleButtonView *)circleButtonView {
    RunsCircleButtonView *view = [[RunsCircleButtonView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
    view.center = CGPointMake(self.center.x, RCK_SCREEN_HEIGHT - 26 - view.frame.size.height * 0.5);
    view.delegate = self;
    view.videoInterval = self.videoInterval;
    return view;
}

@end
































