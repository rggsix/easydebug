//
//  NSObject+EZDAddition.h
//  HoldCoin
//
//  Created by Song on 2018/10/18.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EZDAddition)

- (NSString *)ezd_description;
- (void)ezd_printAllPropertys;

+ (bool)isSubClassAndNotItSelf:(Class)cls;

@end
