//
//  EZDNSLogHooker.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDNSLogHooker.h"

#import "fishhook.h"

#import "EasyDebug.h"
#import "EazyDebug+Private.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

static NSArray<kEZDLogLevel> *ezd_logRefuseLevels = nil;

@implementation EZDNSLogHooker

#if EZDEBUG_DEBUGLOG

///  orgin NSLog
static void (*ezd_origin_NSLog)(NSString *format,...);

///  Hooked NSLog
void _EZDLog(NSString *format,...) {
    va_list va;
    va_start(va, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    
    if (str.length < 4) {
        //  不符合规范的Log
        EZDBLLLog(@"%@", str);
        return;
    }
    
    NSString *levelStr = [str substringWithRange:NSMakeRange(0, 4)];
    if (![levelStr hasPrefix:@"["] || ![levelStr hasSuffix:@"] "]) {
        //  不符合规范的Log
        EZDBLLLog(@"%@", str);
        return;
    }
    
    ezd_origin_NSLog(str);
    
    //  record to Eazydebug
    NSString *callfrom = ezd_methodCallInfo();
    [EasyDebug recordEventWithTypeName:kEZDConsoleType abstractString:str parameter:@{@"log":str, @"from":callfrom} timeStamp:0];
}

NSString* ezd_methodCallInfo() {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    NSString *callInfo;
    if (strs[3]) {
        callInfo = [NSString stringWithUTF8String:strs[3]];
    }

    if ([callInfo containsString:@" -["]) {
        NSRange range = [callInfo rangeOfString:@" -["];
        callInfo = [callInfo substringFromIndex:range.location + range.length - 2];
    }
    else if ([callInfo containsString:@" +["]) {
        NSRange range = [callInfo rangeOfString:@" +["];
        callInfo = [callInfo substringFromIndex:range.location + range.length - 2];
    }
    
    return EZD_NotNullString(callInfo);
}

+ (void)hookNSLog {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Hooking NSLog...");
        
        struct rebinding nslogbind;
        
        nslogbind.name = "NSLog";
        nslogbind.replacement = _EZDLog;
        nslogbind.replaced = (void*)&ezd_origin_NSLog;
        
        struct rebinding rebinds[] = {nslogbind};
        rebind_symbols(rebinds, 1);
    });
}

+ (void)setLogLevel:(NSString *)level {
    NSArray<kEZDLogLevel> *levels = @[
        kEZDLogLevelDebug,
        kEZDLogLevelInfo,
        kEZDLogLevelWarning,
        kEZDLogLevelError,
        kEZDLogLevelFatal
    ];
    
    NSInteger index = [levels indexOfObject:level];
    ezd_logRefuseLevels = [levels subarrayWithRange:NSMakeRange(0, index)];
}

#else

+ (void)hookNSLog {}
+ (void)setLogLevel:(NSString *)level {}

#endif

@end
