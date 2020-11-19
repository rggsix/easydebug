//
//  EZDAPMHooker.m
//  HoldCoin
//
//  Created by Song on 2019/1/25.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMHooker.h"

#import <objc/runtime.h>

#import "EZDAPMUtil.h"
#import "EZDAPMOperationRecorder.h"

#define GET_CLASS_CUSTOM_SEL(sel,class)  NSSelectorFromString([NSString stringWithFormat:@"%@_%@",NSStringFromClass(class),NSStringFromSelector(sel)])

@implementation EZDAPMHooker

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
#if EZDEBUG_DEBUGLOG
    Method originalMethod = class_getInstanceMethod(mclass, originSEL);
    Method newMethod = class_getInstanceMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                    method_getImplementation(newMethod),
                    method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
#endif
}

+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL
                           mclass:(Class)mclass{
#if EZDEBUG_DEBUGLOG
    mclass = object_getClass(mclass);
    
    Method originalMethod = class_getClassMethod(mclass, originSEL);
    Method newMethod = class_getClassMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                               method_getImplementation(newMethod),
                               method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
#endif
}

@end

#if EZD_APM

#pragma mark - Exchaged methods
@implementation UIViewController (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(viewWillAppear:) newMethod:@selector(ezdapm_viewWillAppear:) mclass:[UIViewController class]];
    [EZDAPMHooker exchangeOriginMethod:@selector(viewDidAppear:) newMethod:@selector(ezdapm_viewDidAppear:) mclass:[UIViewController class]];
    [EZDAPMHooker exchangeOriginMethod:@selector(viewWillDisappear:) newMethod:@selector(ezdapm_viewWillDisappear:) mclass:[UIViewController class]];
}

- (void)ezdapm_viewWillAppear:(bool)animated{
    [self ezdapm_viewWillAppear:animated];
}

- (void)ezdapm_viewDidAppear:(bool)animated{
    
    NSString *vcClassName = NSStringFromClass([self class]);
    if ([vcClassName isEqualToString:@"UIInputWindowController"]
        || [vcClassName isEqualToString:@"UIAlertController"]
        || [self isKindOfClass:[UINavigationController class]]
        || [self isKindOfClass:[UITabBarController class]]) {
        vcClassName = @"";
    }
    
    if (vcClassName.length) {
        [EZDAPMUtil shareInstance].lastVCName = [EZDAPMUtil shareInstance].currentVCName;
        [EZDAPMOperationRecorder recordOperation:vcClassName operationType:EZDAPMOperationPageAppear  filePath:@""];
        [EZDAPMUtil shareInstance].currentVCName = vcClassName;
    }
    
    [self ezdapm_viewDidAppear:animated];
}

- (void)ezdapm_viewWillDisappear:(bool)animated{
    [self ezdapm_viewWillDisappear:animated];
}

@end

@implementation UITableView (EZDAPMHook)

+ (void)load{
    NSString *selPart1 = @"_userSelectRowAtPending";
    NSString *selPart2 = @"SelectionIndexPath:";
    SEL selectMethod = NSSelectorFromString([NSString stringWithFormat:@"%@%@", selPart1, selPart2]);
    [EZDAPMHooker exchangeOriginMethod:selectMethod newMethod:@selector(ezd_userSelectRowAtPendingSelectionIndexPath:) mclass:[UITableView class]];
}

- (void)ezd_userSelectRowAtPendingSelectionIndexPath:(NSIndexPath *)indexPath {
    [self ezd_userSelectRowAtPendingSelectionIndexPath:indexPath];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@[i:%ld]=>%@", [EZDAPMUtil shareInstance].currentVCName,NSStringFromClass([cell class]), indexPath.row, @"tableViewSelectRow"] operationType:EZDAPMOperationClick  filePath:@""];
}

@end

@implementation UICollectionView (EZDAPMHook)

+ (void)load{
    NSString *selPart1 = @"_userSelectItem";
    NSString *selPart2 = @"AtIndexPath:";
    SEL selectMethod = NSSelectorFromString([NSString stringWithFormat:@"%@%@", selPart1, selPart2]);
    [EZDAPMHooker exchangeOriginMethod:selectMethod newMethod:@selector(ezd_userSelectItemAtIndexPath:) mclass:[UICollectionView class]];
}

- (void)ezd_userSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self ezd_userSelectItemAtIndexPath:indexPath];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@[i:%ld]=>%@", [EZDAPMUtil shareInstance].currentVCName, NSStringFromClass([cell class]), indexPath.row, @"collectionViewSelectRow"] operationType:EZDAPMOperationClick  filePath:@""];
}

@end

@implementation UIControl (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(sendAction:to:forEvent:) newMethod:@selector(ezdapm_sendAction:to:forEvent:) mclass:[UIControl class]];
}

- (void)ezdapm_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@=>%@", [EZDAPMUtil shareInstance].currentVCName,NSStringFromClass([self class]), NSStringFromSelector(action)] operationType:EZDAPMOperationClick  filePath:@""];
    
    [self ezdapm_sendAction:action to:target forEvent:event];
}

@end


@interface UIView (EZDAPMHook)

- (void)ezdapm_responseGesture:(UIGestureRecognizer *)ges;

@end

@implementation UIGestureRecognizer (EZDAPMHook)

+ (void)load {
    [EZDAPMHooker exchangeOriginMethod:@selector(initWithTarget:action:) newMethod:@selector(ezd_initWithTarget:action:) mclass:[UIGestureRecognizer class]];
    [EZDAPMHooker exchangeOriginMethod:@selector(addTarget:action:) newMethod:@selector(ezd_addTarget:action:) mclass:[UIGestureRecognizer class]];
}

- (void)ezd_trackGestureRecognizerAppClick:(UIGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@=>%@",[EZDAPMUtil shareInstance].currentVCName, NSStringFromClass([ges.view class]), NSStringFromClass([ges class])] operationType:EZDAPMOperationGesBegin  filePath:@""];
    }
}

- (instancetype)ezd_initWithTarget:(id)target action:(SEL)action {
    [self ezd_initWithTarget:target action:action];
    [self removeTarget:target action:action];
    [self addTarget:target action:action];
    return self;
}

- (void)ezd_addTarget:(id)target action:(SEL)action {
    if ([self isKindOfClass:[UITapGestureRecognizer class]]
        || [self isKindOfClass:[UILongPressGestureRecognizer class]]) {
        [self ezd_addTarget:self action:@selector(ezd_trackGestureRecognizerAppClick:)];
    }
    [self ezd_addTarget:target action:action];
}

@end

#endif
