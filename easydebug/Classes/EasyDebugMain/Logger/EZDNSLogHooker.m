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

#include <libkern/OSAtomic.h>
#include <execinfo.h>

@implementation EZDNSLogHooker

///  orgin NSLog
static void (*ezd_origin_NSLog)(NSString *format,...);

///  Hooked NSLog
void _EZDLog(NSString *format,...) {
    va_list va;
    va_start(va, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    ezd_origin_NSLog(str);
    
    //  record to Eazydebug
    NSString *callfrom = ezd_methodCallInfo();
    EZDRecordEvent(@"NSLog", str, (@{@"log":str, @"from":callfrom}), 0);
}

NSString* ezd_methodCallInfo() {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    NSString *callInfo;
    if (strs[2]) {
        callInfo = [NSString stringWithUTF8String:strs[2]];
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

@end
