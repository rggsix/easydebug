//
//  EZDBaseLogInfoController.h
//  HoldCoin
//
//  Created by Song on 2018/10/17.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZDLoggerModel;

@interface EZDBaseLogInfoController : UIViewController

- (instancetype)initWithLogModel:(EZDLoggerModel *)logModel;

@end
