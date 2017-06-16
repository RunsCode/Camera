//
//  RunsCircleButtonViewDelegate.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunsCircleButtonViewDelegate <NSObject>
- (void)buttonView:(UIView *)button didClickTap:(UITapGestureRecognizer *)tapGes;
- (void)buttonView:(UIView *)button didLongTapBegan:(UITapGestureRecognizer *)tapGes;
- (void)buttonView:(UIView *)button didLongTapEnded:(UITapGestureRecognizer *)tapGes;
@end
