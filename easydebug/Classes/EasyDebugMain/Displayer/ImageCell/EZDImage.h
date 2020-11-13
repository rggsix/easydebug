//
//  EZDImage.h
//  HoldCoin
//
//  Created by Song on 2018/10/18.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    EZDImageTypeError,
    EZDImageTypeRollback,
    EZDImageTypeCorrect,
} EZDImageType;

@interface EZDImage : NSObject

+ (UIImage *)imageWithType:(EZDImageType)type;

@end
