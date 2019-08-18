//
//  NSDate+EZDAddition.m
//  HoldCoin
//
//  Created by Song on 2018/10/8.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "NSDate+EZDAddition.h"

@implementation NSDate (EZDAddition)

- (NSString *)ezd_stringWithISOFormat {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    });
    return [formatter stringFromDate:self];
}

@end
