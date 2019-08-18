//
//  EZDSystemUtil.h
//  easydebug
//
//  Created by EDZ on 2019/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDSystemUtil : NSObject

+ (UIWindow *)currentWindow;
+ (BOOL)isIPhoneX;
+ (CGFloat)navigationBarHeight;

@end

NS_ASSUME_NONNULL_END
