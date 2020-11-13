//
//  EZDMenuInfoModel.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDMenuInfoModel.h"

@implementation EZDMenuInfoModel

- (instancetype)initWithTitle:(NSString *)title type:(EZDMenuType)type {
    if (self = [super init]) {
        self.title = title;
        self.menuType = type;
    }
    return self;
}

@end
