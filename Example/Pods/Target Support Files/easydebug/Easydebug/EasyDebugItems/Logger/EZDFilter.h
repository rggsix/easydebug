//
//  EZDFilter.h
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZDLoggerModel;

@interface EZDFilter : NSObject

@property (strong,nonatomic) NSMutableArray<NSString *> *filterItems;

- (instancetype)initWithName:(NSString *)name;

- (void)addFilterItemsObject:(NSString *)object;
- (void)removeFilterItemsObject:(NSString *)object;
- (void)removeAllFilterItems;

- (BOOL)judgeLogModel:(EZDLoggerModel *)logModel;

+ (NSArray<NSString *> *)typeNames;
+ (void)regiestTypeName:(NSString *)typeName;

@end
