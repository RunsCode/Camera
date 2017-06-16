//
//  UIImage+Configure.h
//  Hey
//
//  Created by Dev_Wang on 2017/6/1.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Configure)
- (UIImage *)rs_fixOrientation;
+ (UIImage *)rs_fetchVideoPreViewImageWithUrl:(NSURL *)videoUrl;
+ (UIImage *)rs_thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
@end
