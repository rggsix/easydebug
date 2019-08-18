//
//  EZDMessageHUD.h
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZDImage.h"

@interface EZDMessageHUD : UIView

+ (void)showMessageHUDWithText:(NSString *)text type:(EZDImageType)type;

@end
