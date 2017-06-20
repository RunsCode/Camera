//
//  RunsCameraViewController.h
//  Hey
//
//  Created by wang on 2017/5/28.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunsCameraControllerDelegate.h"
@interface RunsCameraViewController : UIViewController
@property (nonatomic, assign) NSTimeInterval videoInterval;//默认十秒
@property (nonatomic, weak) id<RunsCameraControllerDelegate> delegate;
@end
