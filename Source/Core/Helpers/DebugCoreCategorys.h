//
//  DebugCoreCategorys.h
//  EasyDebug
//
//  Created by songheng on 2020/12/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSObject分类
 */
@interface NSObject (EasyDebug)

///  JSON description(Pretty print)
- (NSString *)dg_JSONDescription;

@end

/**
 NSDate分类
 */
@interface NSDate (EasyDebug)

- (NSString *)dg_stringWithISOFormat;
- (NSString *)dg_dayString;
- (NSString *)dg_timeString;

@end

/**
 UIViewController分类
 */
@interface UIViewController (EasyDebug)

///  找到当前可用的controller.
+ (instancetype)dg_currentController;

+ (void)dg_presentController:(UIViewController *)controller
                     needNav:(BOOL)needNav;

@end

/**
 UIView分类
 */
@interface UIView (EasyDebug_frame)

@property (nonatomic, assign) CGFloat dg_x;
@property (nonatomic, assign) CGFloat dg_y;
@property (nonatomic, assign) CGFloat dg_width;
@property (nonatomic, assign) CGFloat dg_height;
@property (nonatomic, assign) CGPoint dg_origin;
@property (nonatomic, assign) CGSize  dg_size;
@property (nonatomic, assign) CGFloat dg_maxX;
@property (nonatomic, assign) CGFloat dg_maxY;
@property (nonatomic, assign) CGFloat dg_centerX;
@property (nonatomic, assign) CGFloat dg_centerY;

@end

NS_ASSUME_NONNULL_END
