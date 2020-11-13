//
//  EZDOptions.h
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EZDOptionItem.h"
#import "EZDDefine.h"

@class EZDOptionItem;

@protocol EZDOptionProtocol <NSObject>

@required
- (NSArray<EZDOptionItem *> *)optionItems;
///  handle operation and return the result
- (void)didOperaionOptionCell:(EZDOptionItem *)optionItem atRow:(NSInteger)row callback:(void(^)(EZDOptionItem *handledItem))callback;

@end
   
@interface EZDOptions : NSObject<EZDOptionProtocol>

@property (strong,nonatomic) NSUserDefaults *userDefaultOptions;

+ (instancetype)shareOptionInstance;

+ (void)regiestOptionInstace:(Class)optionHandleClass;
+ (instancetype)currentOptionInstance;

@end
