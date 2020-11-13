//
//  EZDSystemUtil.m
//  easydebug
//
//  Created by EDZ on 2019/8/18.
//

#import "EZDSystemUtil.h"

@implementation EZDSystemUtil

+ (UIWindow *)currentWindow{
    __block UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (![window isKeyWindow]) {
        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKeyWindow]) {
                window = obj;
                *stop = YES;
            }
        }];
    }
    return window;
}

+ (BOOL)isIPhoneX{
    static BOOL isX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isX = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
    });
    return isX;
}

+ (CGFloat)navigationBarHeight{
    static CGFloat navHeight = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
        navHeight = statusRect.size.height+([self isIPhoneX] ? 88 : 64);
    });
    return navHeight;
}

@end
