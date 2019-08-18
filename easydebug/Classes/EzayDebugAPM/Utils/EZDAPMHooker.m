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
}

+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
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
}

@end

#if EZD_APM
@implementation NSObject (EZDAPMHook)

//- (void)ezdapm_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%ld",[self className],indexPath.item] operationType:EZDAPMOperationTableViewSelect];
//
//    [self ezdapm_tableView:tableView didSelectRowAtIndexPath:indexPath];
//}
//
//- (void)ezdapm_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%ld",[self className],indexPath.item] operationType:EZDAPMOperationCollectionViewSelect];
//
//    [self ezdapm_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
//}

@end

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
    
    NSString *vcClassName = [self className];
    if ([vcClassName isEqualToString:@"UIInputWindowController"]
        || [vcClassName isEqualToString:@"UIAlertController"]
        || [self isKindOfClass:[UINavigationController class]]
        || [self isKindOfClass:[UITabBarController class]]) {
        vcClassName = @"";
    }
    
    if (vcClassName.length) {
        [EZDAPMUtil shareInstance].lastVCName = [EZDAPMUtil shareInstance].currentVCName;
        [EZDAPMOperationRecorder recordOperation:vcClassName operationType:EZDAPMOperationPageAppear];
        [EZDAPMUtil shareInstance].currentVCName = vcClassName;
    }
    
    [self ezdapm_viewDidAppear:animated];
}

- (void)ezdapm_viewWillDisappear:(bool)animated{
    [self ezdapm_viewWillDisappear:animated];
}

@end

//@implementation UITableView (EZDAPMHook)
//
//+ (void)load{
//    [EZDAPMHooker exchangeOriginMethod:@selector(setDelegate:) newMethod:@selector(ezdapm_setDelegate:) mclass:[UITableView class]];
//}
//
//- (void)ezdapm_setDelegate:(id<UITableViewDelegate>)delegate{
//    [EZDAPMHooker exchangeOriginMethod:@selector(tableView:didSelectRowAtIndexPath:) newMethod:@selector(ezdapm_tableView:didSelectRowAtIndexPath:) mclass:[delegate class]];
//    [self ezdapm_setDelegate:delegate];
//}
//
//@end
//
//@implementation UICollectionView (EZDAPMHook)
//
//+ (void)load{
//    [EZDAPMHooker exchangeOriginMethod:@selector(setDelegate:) newMethod:@selector(ezdapm_setDelegate:) mclass:[UICollectionView class]];
//}
//
//- (void)ezdapm_setDelegate:(id<UITableViewDelegate>)delegate{
//    [EZDAPMHooker exchangeOriginMethod:@selector(collectionView:didSelectItemAtIndexPath:) newMethod:@selector(ezdapm_collectionView:didSelectItemAtIndexPath:) mclass:[delegate class]];
//    [self ezdapm_setDelegate:delegate];
//}
//
//@end

@implementation UIControl (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(sendAction:to:forEvent:) newMethod:@selector(ezdapm_sendAction:to:forEvent:) mclass:[UIControl class]];
}

- (void)ezdapm_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@",[self className], NSStringFromSelector(action)] operationType:EZDAPMOperationClick];
    
    [self ezdapm_sendAction:action to:target forEvent:event];
}

@end


@interface UIView (EZDAPMHook)

- (void)ezdapm_responseGesture:(UIGestureRecognizer *)ges;

@end

@implementation UIView (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(addGestureRecognizer:) newMethod:@selector(ezdapm_addGestureRecognizer:) mclass:[UIView class]];
}

- (void)ezdapm_addGestureRecognizer:(UIGestureRecognizer *)ges{
    if ([ges isKindOfClass:[UITapGestureRecognizer class]] ||
        [ges isKindOfClass:[UILongPressGestureRecognizer class]] ||
        [ges isKindOfClass:[UIPinchGestureRecognizer class]]) {
        [ges addTarget:self action:@selector(ezdapm_responseGesture:)];
    }
    
    [self ezdapm_addGestureRecognizer:ges];
}

- (void)ezdapm_responseGesture:(UIGestureRecognizer *)ges{
    if (ges.state == UIGestureRecognizerStateBegan) {
        [EZDAPMOperationRecorder recordOperation:[NSString stringWithFormat:@"%@=>%@=>%@",[EZDAPMUtil shareInstance].currentVCName,[self className],[ges className]] operationType:EZDAPMOperationGesBegin];
    }
}

@end

@implementation UIGestureRecognizer (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(addTarget:action:) newMethod:@selector(ezdapm_addTarget:action:) mclass:[UIGestureRecognizer class]];
}

- (void)ezdapm_addTarget:(id)target action:(SEL)action{
    if (![NSStringFromSelector(action) isEqualToString:@"trackGestureRecognizerAppClick:"] &&
        [target isKindOfClass:[UIView class]]) {
        [self ezdapm_addTarget:(UIView *)target action:@selector(ezdapm_responseGesture:)];
    }
    
    [self ezdapm_addTarget:target action:action];
}

@end

#endif
