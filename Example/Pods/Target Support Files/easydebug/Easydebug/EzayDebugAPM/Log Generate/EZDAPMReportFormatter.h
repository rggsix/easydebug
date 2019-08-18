//
//  EZDAPMReportFormatter.h
//  HoldCoin
//
//  Created by Song on 2019/1/24.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CrashReporter/CrashReporter.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDAPMReportFormatter : NSObject<PLCrashReportFormatter>

+ (NSString *)plframe_reportStringWithReport:(PLCrashReport *)report traceInfo:(bool)traceInfo operationInfo:(bool)operationInfo;

+ (NSString *)reportStringWithTraceInfo:(bool)traceInfo onlyMainThread:(bool)onlyMainThread operationInfo:(bool)operationInfo;

@end

NS_ASSUME_NONNULL_END
