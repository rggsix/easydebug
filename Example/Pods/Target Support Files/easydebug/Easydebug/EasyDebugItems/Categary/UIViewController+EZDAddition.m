//
//  UIViewController+EZDAddition.m
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "UIViewController+EZDAddition.h"

#import "EZDDefine.h"

@implementation UIViewController (EZDAddition)

+ (instancetype)ezd_useableController{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (!rootVC) {
        rootVC = kHCKeyWindow.rootViewController;
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

+ (void)presentIfCanWithController:(UIViewController *)controller needNavigationController:(BOOL)needNav{
    UIViewController *presentVC = [UIViewController ezd_useableController];
    if (!presentVC) {
        EZDLog(@"Can't find useable view controller to present EZDDisplayController!");
        return;
    }
    
    if (needNav) {
        controller = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    [presentVC presentViewController:controller animated:false completion:nil];
}

@end
