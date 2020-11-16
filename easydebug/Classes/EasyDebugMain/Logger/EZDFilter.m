//
//  EZDFilter.m
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDFilter.h"
#import "EZDDefine.h"
#import "NSObject+EZDAddition.h"
#import "EZDLoggerModel.h"

static NSMutableSet<NSString *> *typeNameSet = nil;

@interface EZDFilter ()

@property (copy,nonatomic) NSString *filterName;
@property (strong,nonatomic) NSUserDefaults *filterUserDefault;

@end

@implementation EZDFilter

- (instancetype)initWithName:(NSString *)name{
    if (self = [super init]) {
        name = [@"EZDFilter->" stringByAppendingString:name];
        self.filterName = name;
        self.filterUserDefault = [[NSUserDefaults alloc] initWithSuiteName:kEZDUserDefaultSuiteName];
        self.filterItems = [[self.filterUserDefault arrayForKey:name] mutableCopy];
        if (!self.filterItems) {
            self.filterItems = [NSMutableArray new];
        }
    }
    return self;
}

- (void)addFilterItemsObject:(NSString *)object{
    if (object.length && ![self.filterItems containsObject:object]) {
        [self.filterItems addObject:object];
    }
    [self.filterUserDefault setObject:self.filterItems forKey:self.filterName];
}

- (void)removeFilterItemsObject:(NSString *)object{
    [self.filterItems removeObject:object];
    [self.filterUserDefault setObject:self.filterItems forKey:self.filterName];
}

- (void)removeAllFilterItems{
    [self.filterItems removeAllObjects];
    [self.filterUserDefault setObject:self.filterItems forKey:self.filterName];
}

- (BOOL)judgeLogModel:(EZDLoggerModel *)logModel{
    if (!self.filterItems.count) {
        return true;
    }
    
    __block bool filful = false;
    [self.filterItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[logModel.typeName lowercaseString] containsString:[obj lowercaseString]]) {
            filful = true;
            *stop = true;
        }
    }];
    
    if (filful) {
        return filful;
    }
    
    [logModel.parameter.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        filful = [self judgeObject:obj];
        if (filful) {
            *stop = true;
        }
    }];
    return filful;
}

- (BOOL)judgeObject:(id)object{
// L3 Performance issue
    NSString *des = [[object ezd_description] lowercaseString];
    for (NSString *filterItem in self.filterItems) {
        if ([des containsString:[filterItem lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray<NSString *> *)typeNames{
    if (!typeNameSet) {
        typeNameSet = [NSMutableSet new];
    }
    return [typeNameSet allObjects];
}

+ (void)regiestTypeName:(NSString *)typeName{
    if (!typeNameSet) {
        typeNameSet = [NSMutableSet new];
    }
    typeName.length ? [typeNameSet addObject:typeName] : nil;
}

@end
