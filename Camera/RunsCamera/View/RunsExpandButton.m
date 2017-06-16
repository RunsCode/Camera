//
//  RunsExpandButton.m
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import "RunsExpandButton.h"

@implementation RunsExpandButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //当前btn大小
    CGRect btnBounds = self.bounds;
    //扩大点击区域，想缩小就将-10设为正值
    btnBounds = CGRectInset(btnBounds, -self.expandPoint.x, -self.expandPoint.x);
    
    //若点击的点在新的bounds里，就返回YES
    return CGRectContainsPoint(btnBounds, point);
}

@end
