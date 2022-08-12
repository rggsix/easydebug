//
//  DebugCoreCategorys.m
//  EasyDebug
//
//  Created by songheng on 2020/12/9.
//

#import "DebugCoreCategorys.h"

#import <objc/message.h>
#import "DebugCoreCategorys.h"
#import "EasyDebug.h"
#import "EasyDebugUtil.h"

@implementation NSObject (EasyDebug)

- (NSString *)dg_JSONDescription{
    NSString *jsonStr = [self qt_JSONString];
    if (!jsonStr.length) {
        jsonStr = [self description];
    }
    return jsonStr;
}

- (NSString *)qt_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    } else if ([[self class] isSubclassOfClass:[NSNumber class]]){
        return [self description];
    } else if ([self isKindOfClass:[NSError class]]) {
        return [self description];
    }
    
    //  尽管不建议直接把Object塞进content, 但是依然提供了简单的把Object转换为Dict的过程，尽量为log提供更多信息
    NSString *desStr = [self description];
    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id dataObj = self;
        if ([self respondsToSelector:NSSelectorFromString(@"yy_modelToJSONObject")]) {
            dataObj = [self performSelector:NSSelectorFromString(@"yy_modelToJSONObject")];
        } else if ([self respondsToSelector:NSSelectorFromString(@"mj_keyValues")]) {
            dataObj = [self performSelector:NSSelectorFromString(@"mj_keyValues")];
        }
#pragma clang diagnostic pop
        desStr = [[[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataObj options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    } @catch (NSException *exception) {
        
    } @finally {
        return desStr;
    }
}

@end


@implementation NSDate (EasyDebug)

- (NSString *)dg_stringWithISOFormat {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    });
    return [formatter stringFromDate:self];
}

- (NSString *)dg_dayString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy年MM月dd日";
    });
    return [formatter stringFromDate:self];
}

- (NSString *)dg_timeString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"HH:mm:ss";
    });
    return [formatter stringFromDate:self];
}

@end


@implementation UIViewController (EasyDebug)

+ (instancetype)dg_currentController{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootVC) {
        rootVC = [EasyDebugUtil currentWindow].rootViewController;
    }
    if (!rootVC) {
        return nil;
    }
    return [self topViewControllerWithRootViewController:rootVC];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

+ (void)dg_presentController:(UIViewController *)controller
                     needNav:(BOOL)needNav{
    UIViewController *presentVC = [UIViewController dg_currentController];
    if (!presentVC) {
        [EasyDebug logConsole:@"[EasyDebug] Can't find useable view controller to present DebugStartupController!"];
        return;
    }
    
    if (needNav) {
        controller = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [presentVC presentViewController:controller animated:false completion:nil];
}

@end


@implementation UIView (EasyDebug_frame)

- (void)setDg_x:(CGFloat)dg_x{
    CGRect frame = self.frame;
    frame.origin.x = dg_x;
    self.frame = frame;
}

- (void)setDg_y:(CGFloat)dg_y{
    CGRect frame = self.frame;
    frame.origin.y = dg_y;
    self.frame = frame;
}

- (CGFloat)dg_x{
    return self.frame.origin.x;
}

- (CGFloat)dg_y{
    return self.frame.origin.y;
}

- (void)setDg_centerX:(CGFloat)dg_centerX{
    CGPoint center = self.center;
    center.x = dg_centerX;
    self.center = center;
}

- (CGFloat)dg_centerX{
    return self.center.x;
}

- (void)setDg_centerY:(CGFloat)dg_centerY{
    CGPoint center = self.center;
    center.y = dg_centerY;
    self.center = center;
}

- (CGFloat)dg_centerY{
    return self.center.y;
}

- (void)setDg_maxX:(CGFloat)dg_maxX{
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = dg_maxX - self.dg_width;
    self.frame = tempFrame;
}

- (CGFloat)dg_maxX{
    return self.dg_x+self.dg_width;
}

- (void)setDg_maxY:(CGFloat)dg_maxY{
    CGRect tempFrame = self.frame;
    tempFrame.origin.y = dg_maxY - self.dg_height;
    self.frame = tempFrame;
}
- (CGFloat)dg_maxY{
    return self.dg_y+self.dg_height;
}

- (void)setDg_width:(CGFloat)dg_width{
    CGRect frame = self.frame;
    frame.size.width = dg_width;
    self.frame = frame;
}

- (void)setDg_height:(CGFloat)dg_height{
    CGRect frame = self.frame;
    frame.size.height = dg_height;
    self.frame = frame;
}

- (CGFloat)dg_height{
    return self.frame.size.height;
}

- (CGFloat)dg_width{
    return self.frame.size.width;
}

- (void)setDg_size:(CGSize)dg_size{
    CGRect frame = self.frame;
    frame.size = dg_size;
    self.frame = frame;
}

- (CGSize)dg_size{
    return self.frame.size;
}

- (void)setDg_origin:(CGPoint)dg_origin{
    CGRect frame = self.frame;
    frame.origin = dg_origin;
    self.frame = frame;
}

- (CGPoint)dg_origin{
    return self.frame.origin;
}

@end
