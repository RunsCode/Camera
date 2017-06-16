//
//  RunsCircleButtonView.m
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsCircleButtonView.h"
#import "RunsCameraKit.h"
#import "ZFProgressView.h"
#define CIRCLE_RATE (1.2)

@interface RunsCircleButtonView () <UIGestureRecognizerDelegate>

@end

@implementation RunsCircleButtonView {
    BOOL isVideoCapture;
    BOOL isEffectiveVideo;
    
    ZFProgressView *circleProgressView;
    UIImageView *topImageView;
    UIImageView *bottomImageView;
    CGSize topImageViewOriginSize;
    CGSize bottomImageViewOriginSize;
    
    dispatch_source_t longTapQueueTimer;
}

- (void)dealloc {
    RCKLog(@"RunsCircleButtonView Release")
    [self stop];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.circleProgressView];
        [self addSubview:self.bottomImageView];
        [self addSubview:self.topImageView];
        [self addGestureRecognizer:self.clickTap];
        [self addGestureRecognizer:self.longTap];
    }
    return self;
}

- (void)setVideoInterval:(NSTimeInterval)videoInterval {
    _videoInterval = videoInterval > 0 ? videoInterval : 10;
}

- (void)start {
    RCKLog(@"start")
    circleProgressView.hidden = NO;
    if (!isVideoCapture)  return;
    dispatch_resume(self.longTapQueueTimer);
}

- (void)stop {
    RCKLog(@"stop")
    isVideoCapture = NO;
    if (longTapQueueTimer) {
        dispatch_source_cancel(longTapQueueTimer);
    }
    [circleProgressView setProgress:0.0 Animated:NO];
    circleProgressView.hidden = YES;
}

- (void)resume {
    RCKLog(@"resume")
    [self stop];
    [self restoreFrame];
}

- (void)expandAnimation {
    RCKLog(@"expandAnimation")
    __block CGFloat bottomRate = CIRCLE_RATE;//self.frame.size.width / bottomImageView.frame.size.width;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        bottomImageView.transform = CGAffineTransformMakeScale(bottomRate, bottomRate);
        bottomImageView.center = self.thisCenter;
        //
        topImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        topImageView.center = self.thisCenter;
    } completion:^(BOOL finished) {
        [self start];
    }];
}

- (void)restoreFrame {
    RCKLog(@"restoreFrame")
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        bottomImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        bottomImageView.frame = CGRectMake(0, 0, bottomImageViewOriginSize.width, bottomImageViewOriginSize.height);
        bottomImageView.center = self.thisCenter;
        //
        topImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        topImageView.frame = CGRectMake(0, 0, topImageViewOriginSize.width, topImageViewOriginSize.height);
        topImageView.center = self.thisCenter;
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark -- 点击事件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resume];
}

- (void)onClickTap:(UITapGestureRecognizer *)tapGes {
    RCKLog(@"点按拍照")
    
    if (isVideoCapture) {
        RCKLog(@"视频捕捉状态 不能进行拍照");
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {
        [_delegate buttonView:self didClickTap:tapGes];
    }
    [self stop];
}

- (void)onLongTap:(UITapGestureRecognizer *)tapGes {
    UIGestureRecognizerState state = tapGes.state;
    if (UIGestureRecognizerStateChanged == state) {
//        RCKLog(@"长按录像按钮状态改变")
        return;
    }
    
    if (!_delegate) {
        RCKLog(@"长按结束没有代理回调")
        return;
    }
    
    if (UIGestureRecognizerStateBegan == state) {
        RCKLog(@"长按录像开始")
        isVideoCapture = YES;
        isEffectiveVideo = NO;
        [self expandAnimation];
        if ([_delegate respondsToSelector:@selector(buttonView:didLongTapBegan:)]) {
            [_delegate buttonView:self didLongTapBegan:tapGes];
        }
        return;
    }
    
    if (UIGestureRecognizerStateEnded == state) {
        RCKLog(@"长按录像结束")
        isVideoCapture = NO;
        if (!isEffectiveVideo && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {
            RCKLog(@"拍摄时长低于一秒 转换给最后一秒拍照")
            [_delegate buttonView:self didClickTap:tapGes];
            [self resume];
            return;
        }
        
        if ([_delegate respondsToSelector:@selector(buttonView:didLongTapEnded:)]) {
            [_delegate buttonView:self didLongTapEnded:tapGes];
        }
    }
    [self resume];
    RCKLog(@"tapGes.state : %ld", (long)state)
}

#pragma mark -- UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)captureVideoOver {
    isVideoCapture = NO;
    if (!isEffectiveVideo && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {
        [self resume];
        return;
    }
    if ([_delegate respondsToSelector:@selector(buttonView:didLongTapEnded:)]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)self.longTap;
        [_delegate buttonView:self didLongTapEnded:tap];
    }
    [self resume];
}

#pragma mark -- init UI and componet

- (UITapGestureRecognizer *)clickTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTap:)];
    tap.delegate = self;
    return tap;
}

- (UILongPressGestureRecognizer *)longTap {
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTap:)];
    tap.minimumPressDuration = 0.1;
    tap.delegate = self;
    return tap;
}

- (UIImageView *)topImageView {
    if (topImageView) return topImageView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView.image = [UIImage imageNamed:@"rs_camera_action_top"];
    imageView.userInteractionEnabled = NO;
    imageView.center = self.thisCenter;
    topImageView = imageView;
    topImageViewOriginSize = imageView.frame.size;
    return topImageView;
}

- (UIImageView *)bottomImageView {
    if (bottomImageView) return bottomImageView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"rs_camera_action_bottom"];
    imageView.userInteractionEnabled = NO;
    imageView.center = self.thisCenter;
    bottomImageView = imageView;
    bottomImageViewOriginSize = bottomImageView.frame.size;
    return bottomImageView;
}

- (ZFProgressView *)circleProgressView {
    if (circleProgressView) return circleProgressView;
    ZFProgressView *progressView = [[ZFProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*CIRCLE_RATE, self.frame.size.height*CIRCLE_RATE)];
    progressView.progressStrokeColor = RCKUIColorFromRGB(0xff757c);// 0xff0000 red 0xfde802 yellow
    progressView.backgroundStrokeColor = [UIColor clearColor];
    progressView.progressLineWidth = 3.0;
    progressView.timeDuration = 0.5;
    progressView.center = self.thisCenter;
    progressView.progress =0;
    progressView.hidden = YES;
    circleProgressView = progressView;
    return circleProgressView;
}

static int count = 0;
- (dispatch_source_t)longTapQueueTimer {
//    dispatch_queue_t queue = dispatch_queue_create("com.RunsCircleButtonView.timer", DISPATCH_QUEUE_CONCURRENT);
    __weak typeof(self) weakSelf = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    uint64_t interval = 0.01 * NSEC_PER_SEC;
    dispatch_source_set_timer(timer, start, interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (count > (_videoInterval*100)) {
            [circleProgressView setProgress:1.0 Animated:NO];
            [weakSelf captureVideoOver];
            RCKLogEX(@"录视频Over")
            return;
        }
        count += 1;
        CGFloat rate = (CGFloat)count/(_videoInterval*100);
        [circleProgressView setProgress:rate Animated:NO];
        isEffectiveVideo = count >= 10;
//        RCKLogEX(@"滴滴 count = %lu, rate = %f", (unsigned long)count, rate)
    });
    dispatch_source_set_cancel_handler(timer, ^{
        count = 0;
    });
    longTapQueueTimer = timer;
    return longTapQueueTimer;
}

- (CGPoint)thisCenter {
    return CGPointMake(self.frame.size.width * 0.5, self.frame.size.height *0.5);
}
@end



















