//
//  EZDAPMBacktrace.h
//  HoldCoin
//
//  Created by Song on 2019/1/23.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDAPMBacktrace : NSObject

+ (NSString *)getCurrentTraceLog;
+ (NSString *)getCurrentTraceLogWithTraceInfo:(BOOL)traceInfo onlyMainThread:(bool)onlyMainThread operationPathInfo:(BOOL)operationPathInfo;

@end

NS_ASSUME_NONNULL_END
