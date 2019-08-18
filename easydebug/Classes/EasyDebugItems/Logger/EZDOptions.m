//
//  EZDOptions.m
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDOptions.h"
#import "EZDDefine.h"

static EZDOptions *ins = nil;

@implementation EZDOptions

+ (instancetype)shareOptionInstance{
    static id options = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = [[self alloc] init];
    });
    return options;
}

+ (void)regiestOptionInstace:(Class)optionHandleClass{
    NSAssert([optionHandleClass isSubclassOfClass:[self class]], @"Option Instance must be subclass of [EZDOptions] !");
    ins = [[optionHandleClass alloc] init];
}

+ (instancetype)currentOptionInstance{
    return ins;
}

#pragma mark - lazy load
- (NSUserDefaults *)userDefaultOptions{
    if (!_userDefaultOptions) {
        _userDefaultOptions = [[NSUserDefaults alloc] initWithSuiteName:kEZDUserDefaultSuiteName];
    }
    return _userDefaultOptions;
}

- (void)didOperaionOptionCell:(EZDOptionItem *)optionItem callback:(void (^)(EZDOptionItem *))callback {
    NSAssert(false, @"didOperaionOptionCell:callback must relization!");
}

- (NSArray<EZDOptionItem *> *)optionItems {
    NSAssert(false, @"optionItems must relization!");
    return nil;
}

- (void)didOperaionOptionCell:(EZDOptionItem *)optionItem atRow:(NSInteger)row callback:(void(^)(EZDOptionItem *handledItem))callback {
    
}

@end
