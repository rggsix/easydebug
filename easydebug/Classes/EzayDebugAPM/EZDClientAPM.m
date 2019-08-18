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

#import "EZDAPMDeviceConsumptionMonitor.h"
#import "EZDAPMFPSMonitor.h"
#import "EZDAPMHTTPProtocol.h"
#import "EZDAPMURLSchemeHandler.h"

@implementation EZDClientAPM

+(void)startMonitoring{
#if EZD_APM
    [EZDAPMHTTPProtocol setupHTTPProtocol];
    [EZDAPMFPSMonitor startFPSMonitoring];
    [EZDAPMDeviceConsumptionMonitor startMonitoring];
    #ifdef __IPHONE_11_0
    [EZDAPMURLSchemeHandler startMonitoring];
    #endif
#endif
}

@end
