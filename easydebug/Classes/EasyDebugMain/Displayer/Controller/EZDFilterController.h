//
//  EZDFilterController.h
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZDLogger.h"

@interface EZDFilterController : UIViewController

- (instancetype)initWithLogger:(EZDLogger *)logger ConfirmCallback:(void(^)(void))confirmCallback;

@end
