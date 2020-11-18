//
//  EZDClientAPM.m
//  HoldCoin
//
//  Created by Song on 2019/1/23.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDClientAPM.h"
#import "EZDAPMBacktrace.h"
#import "EZDAPMUtil.h"
#import "EZDAPMHooker.h"
#import "EZDAPMOperationRecorder.h"

#import "EZDAPMDeviceConsumptionMonitor.h"
#import "EZDAPMFPSMonitor.h"
#import "EZDAPMHTTPProtocol.h"

@interface EZDClientAPM ()<EZDAPMOperationRecorderDelegate>

@property (nonatomic, strong) NSHashTable *ezd_observers;

@end

@implementation EZDClientAPM

+ (instancetype)shareInstance{
    static EZDClientAPM *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [self new];
        ins.ezd_observers = [NSHashTable weakObjectsHashTable];
        [EZDAPMOperationRecorder shareInstance].delegate = ins;
    });
    return ins;
}

+(void)startMonitoring{
#if EZD_APM
    [EZDAPMHTTPProtocol setupHTTPProtocol];
    [EZDAPMFPSMonitor startFPSMonitoring];
    [EZDAPMDeviceConsumptionMonitor startMonitoring];
    [EZDAPMHTTPProtocol WKWebViewNetworkMonitoring:YES];
#endif
}

+ (void)addLogObserver:(id<EZDClientAPMProtocol>)observer{
    EZDClientAPM *apm = [EZDClientAPM shareInstance];
    if ([observer conformsToProtocol:NSProtocolFromString(@"EZDClientAPMProtocol")]
        && ![apm.ezd_observers containsObject:observer]) {
        [apm.ezd_observers addObject:observer];
    }
}

+ (void)removeLogObserver:(id<EZDClientAPMProtocol>)observer{
    EZDClientAPM *apm = [EZDClientAPM shareInstance];
    [apm.ezd_observers removeObject:observer];
}

#pragma mark - EZDAPMOperationRecorderDelegate
- (void)APMOperationRecorderDidRecordNewLog:(EZDAPMOperationType)type filePath:(NSString *)filePath{
    for (id<EZDClientAPMProtocol> observer in self.ezd_observers.copy) {
        if ([observer respondsToSelector:@selector(APMDidGenerateNewLogFile:type:)]) {
            [observer APMDidGenerateNewLogFile:filePath type:type];
        }
    }
}

@end
