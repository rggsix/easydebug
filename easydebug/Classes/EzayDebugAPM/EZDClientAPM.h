//
//  EZDClientAPM.h
//  HoldCoin
//
//  Created by Song on 2019/1/23.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EZDAPMOperationRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EZDClientAPMProtocol <NSObject>

- (void)APMDidGenerateNewLogFile:(NSString *)filePath type:(EZDAPMOperationType)type;

@end

@interface EZDClientAPM : NSObject

+ (void)startMonitoring;

+ (void)addLogObserver:(id<EZDClientAPMProtocol>)observer;
+ (void)removeLogObserver:(id<EZDClientAPMProtocol>)observer;

@end

NS_ASSUME_NONNULL_END
