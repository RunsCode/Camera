//
//  RunsCircleButtonView.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunsCircleButtonViewDelegate.h"

@interface RunsCircleButtonView : UIView
@property (nonatomic, assign) NSTimeInterval videoInterval;
@property (nonatomic, weak) id<RunsCircleButtonViewDelegate> delegate;
@end
