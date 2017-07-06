//
//  RunsCameraView.h
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunsCameraViewDelegate.h"

@interface RunsCameraView : UIView
@property (nonatomic, assign) NSTimeInterval videoInterval;
@property (nonatomic, weak) id<RunsCameraViewDelegate> delegate;
@end
