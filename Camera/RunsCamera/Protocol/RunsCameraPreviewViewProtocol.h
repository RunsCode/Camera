//
//  RunsCameraPreviewViewProtocol.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 www.dev_wang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MediaContentType) {
    Enum_StillImage = 0,
    Enum_VideoURLPath = 1,
    Enum_Default_MediaContentType = 0,
};

@protocol RunsCameraPreviewViewProtocol <NSObject>
@required
- (void)showMediaContentImage:(UIImage *)image withType:(MediaContentType)type;
- (void)showMediaContentVideo:(NSURL *)URLPath withType:(MediaContentType)type;
- (void)clearContent:(BOOL)needClear;
@end
