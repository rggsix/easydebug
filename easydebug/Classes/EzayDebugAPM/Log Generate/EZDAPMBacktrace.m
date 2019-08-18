//
//  EZDAPMBacktrace.m
//  HoldCoin
//
//  Created by Song on 2019/1/23.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMBacktrace.h"
#import "EZDAPMReportFormatter.h"

@implementation EZDAPMBacktrace

+ (NSString *)getCurrentTraceLogWithTraceInfo:(BOOL)traceInfo onlyMainThread:(bool)onlyMainThread operationPathInfo:(BOOL)operationPathInfo{
//    PLCrashReporterSymbolicationStrategy strategy = PLCrashReporterSymbolicationStrategySymbolTable;
//#if TARGET_OS_SIMULATOR
//    strategy = PLCrashReporterSymbolicationStrategyAll;
//#endif
//    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:strategy];
//    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
//    NSData *data = [crashReporter generateLiveReport];
//    PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
//#warning L4 can improve performance if only need operationPathInfo
//    return [EZDAPMReportFormatter reportStringWithReport:reporter traceInfo:traceInfo operationInfo:operationPathInfo];
    return [EZDAPMReportFormatter reportStringWithTraceInfo:traceInfo onlyMainThread:onlyMainThread operationInfo:operationPathInfo];
}

+ (NSString *)getCurrentTraceLog{
    return [self getCurrentTraceLogWithTraceInfo:true  onlyMainThread:false operationPathInfo:true];
}

@end
