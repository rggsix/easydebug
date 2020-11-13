//
//  UIViewController+EZDAddition.h
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (EZDAddition)

///  Find a useable controller in current application.
+ (instancetype)ezd_useableController;

+ (void)presentIfCanWithController:(UIViewController *)controller
                  needNavigationController:(BOOL)needNav;

@end
