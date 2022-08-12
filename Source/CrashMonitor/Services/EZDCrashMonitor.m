//
//  EZDCrashMonitor.m
//  EasyDebug
//
//  Created by songheng on 2020/12/1.
//

#import "EZDCrashMonitor.h"

#import "EZDBackTrace.h"
#import "EasyDebug.h"
#import "EasyDebugUtil.h"
#import "EasyDebug.h"
#import "EZDLogManager.h"
#import "EZDLogModel.h"
#include <execinfo.h>
#import <objc/runtime.h>

static NSString * const DebugUncaughtExceptionHandlerSignalExceptionName = @"DebugUncaughtExceptionHandlerSignalExceptionName";
static NSString * const DebugUncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
static NSString * const DebugUncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
static NSString * const kDebugCrashStoreKey = @"DebugCrashStoreKey";

static NSUncaughtExceptionHandler * dg_previousUncaughtExceptionHandler;

void dg_registerSignalHandler(void);
void dg_resignSignalHandler(void);

void dg_registerNSExceptionHander(void);
void dg_resignNSExceptionHander(void);

@interface EZDCrashMonitor ()

@end

@implementation EZDCrashMonitor

+ (instancetype)shared {
    static EZDCrashMonitor *ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[EZDCrashMonitor alloc] init];
    });
    return ins;
}

#pragma mark - interface

+ (void)config {
    [self.shared config];
}

+ (void)logExceptionFromThirdPlatform:(NSException *)exception {
    //  没开crash 监听，不处理
    if (!EasyDebug.shared.isOn) {
        return;
    }
    
    NSMutableDictionary *userInfo = [[exception userInfo] mutableCopy];
    userInfo[@"fromThird"] = @"YES";
    userInfo[DebugUncaughtExceptionHandlerAddressesKey] = DGNotNullString([[exception callStackSymbols] componentsJoinedByString:@"\n"]);
    NSException *nexp = [NSException exceptionWithName:exception.name reason:exception.reason userInfo:userInfo];
    [EZDCrashMonitor.shared handleExceptionInfo:nexp];
}

#pragma mark - private

- (void)config {
    if (EasyDebug.shared.isOn) {
        [self registerCrashHandlers];
    } else {
        [self resignCrashHandlers];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isOnChanged) name:EasyDebugIsOnChangedNotificationName object:nil];
}

- (void)isOnChanged {
    if (EasyDebug.shared.isOn) {
        [self start];
    }
    else {
        [self stop];
    }
}

- (void)start {
    [self registerCrashHandlers];
}

- (void)stop {
    [self resignCrashHandlers];
}

- (void)registerCrashHandlers {
    //  查看上次是否有crash
    [self checkAndLogLastTimeCrashInfo];
    
    dg_registerNSExceptionHander();
    dg_registerSignalHandler();
}

- (void)resignCrashHandlers {
    dg_resignSignalHandler();
    dg_resignNSExceptionHander();
}

- (void)handleExceptionInfo:(NSException *)exception {
    NSString *crashInfo = [NSString stringWithFormat:
                           @"Exception name : %@\n\
                           Crash Reason : %@\n\
                           UserInfo : %@",
                           exception.name,
                           exception.reason,
                           exception.userInfo];
    
    //  时间可能不太够，有可能在本次没法存进数据库了，存进store里，保证这次信息被保存
    [EasyDebug.shared saveSettingValue:DGNotNullString(crashInfo) forKey:kDebugCrashStoreKey];
    
    [EZDLogManager.shared syncRecordLogWithTag:kDebugCrashLogTag content:@{@"log":DGNotNullString(crashInfo)}];
    //  存储成功，删除xStore存储
    [EasyDebug.shared saveSettingValue:@"" forKey:kDebugCrashStoreKey];
}


- (void)checkAndLogLastTimeCrashInfo {
    //  查看上次是否有crash信息，如果有，再打印一次
    NSString *crashInfo = [EasyDebug.shared getSettingValue:kDebugCrashStoreKey];
    crashInfo = DGNotNullString(crashInfo);
    if (crashInfo.length) {
        [EasyDebug logWithTag:kDebugCrashLogTag log:@"这是上次发生的Crash : \n%@", crashInfo];
    }
    [EasyDebug.shared saveSettingValue:@"" forKey:kDebugCrashStoreKey];
}

#pragma mark - signal handle

void dg_signalHandler(int signal) {
    if (!EasyDebug.shared.isOn) {
        //  没开启，不处理
        return;
    }
    
    NSString *backtrace = [EZDBackTrace dg_backtraceOfCurrentThread];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    userInfo[DebugUncaughtExceptionHandlerSignalKey] = @(signal);
    userInfo[DebugUncaughtExceptionHandlerAddressesKey] = DGNotNullString(backtrace);
    NSString *reason = [NSString stringWithFormat:@"Signal %d was raised.%@", signal, EasyDebugUtil.appShortInfo];
    NSException *exception = [NSException exceptionWithName:DebugUncaughtExceptionHandlerSignalExceptionName
                                                     reason:reason
                                                   userInfo:userInfo];

    [EZDCrashMonitor.shared handleExceptionInfo:exception];
    //为什么会重复收到signal?
    dg_resignSignalHandler();
}

void dg_registerSignalHandler() {
    //    由于abort()函数调用发生的程序中止信号
    signal(SIGABRT, dg_signalHandler);
    //    内存地址未对齐导致的程序中止信号
    signal(SIGBUS, dg_signalHandler);
    //    由于浮点数异常导致的程序中止信号
    signal(SIGFPE, dg_signalHandler);
    //    由于非法指令产生的程序中止信号
    signal(SIGILL, dg_signalHandler);
    //    通过端口发送消息失败导致的程序中止信号
    signal(SIGPIPE, dg_signalHandler);
    //    由于无效内存的引用导致的程序中止信号
    signal(SIGSEGV, dg_signalHandler);
    //    bad argument to system call
    signal(SIGSYS, dg_signalHandler);
    //    trace trap (not reset when caught)
    signal(SIGTRAP, dg_signalHandler);
}

void dg_resignSignalHandler() {
    signal(SIGABRT, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGSYS, SIG_DFL);
    signal(SIGTRAP, SIG_DFL);
}

#pragma mark - NSException Handle
static void dg_uncaught_exception_handler(NSException *exception) {
    if (!EasyDebug.shared.isOn) {
        //  没开启，不处理来自SDK的crash
        //  我们影响了其他人接收信息，需要把信息重新发出去
        resendUnCaughtException(exception);
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
    userInfo[DebugUncaughtExceptionHandlerAddressesKey] = DGNotNullString([[exception callStackSymbols] componentsJoinedByString:@"\n"]);
    NSException *ne = [NSException exceptionWithName:exception.name
                                              reason:exception.reason
                                            userInfo:userInfo];
    [EZDCrashMonitor.shared handleExceptionInfo:ne];
    //  把crash信息重新发送出去
    resendUnCaughtException(exception);
}

void resendUnCaughtException(NSException *exception) {
    if (dg_previousUncaughtExceptionHandler) {
        dg_previousUncaughtExceptionHandler(exception);
    }
}

void dg_registerNSExceptionHander() {
    //  存储已经注册的handler，在我们处理结束后将exception传下去
    void *pre = NSGetUncaughtExceptionHandler();
    if (pre != dg_uncaught_exception_handler) {
        dg_previousUncaughtExceptionHandler = pre;
        NSSetUncaughtExceptionHandler(&dg_uncaught_exception_handler);
    }
}

void dg_resignNSExceptionHander() {
    if (dg_uncaught_exception_handler != NSGetUncaughtExceptionHandler()) {
        return;
    }
    if (dg_previousUncaughtExceptionHandler) {
        NSSetUncaughtExceptionHandler(dg_previousUncaughtExceptionHandler);
        dg_previousUncaughtExceptionHandler = nil;
    } else {
        NSSetUncaughtExceptionHandler(NULL);
    }
}

@end
