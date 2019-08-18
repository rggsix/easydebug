//
//  EZDLoggerModel.m
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDLoggerModel.h"
#import "NSDate+EZDAddition.h"

@implementation EZDLoggerModel

+ (instancetype)modelWithTypeName:(NSString *)typeName abstractString:(NSString *)abstractString parameter:(NSDictionary *)parameter timeStamp:(NSTimeInterval)timeStamp{
    EZDLoggerModel *model = [EZDLoggerModel new];
    model.typeName = typeName;
    model.abstractString = abstractString;
    model.parameter = parameter;
    model.timeStamp = timeStamp ? timeStamp : [[NSDate date] timeIntervalSince1970];
    model.dateDes = [[NSDate dateWithTimeIntervalSince1970:model.timeStamp] ezd_stringWithISOFormat];
    return model;
}

- (NSString *)displayTypeName{
    return _displayTypeName.length ? _displayTypeName : _typeName;
}

@end
