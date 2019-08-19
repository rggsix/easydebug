//
//  EZDViewController.m
//  easydebug
//
//  Created by Song on 08/21/2018.
//  Copyright (c) 2018 Song. All rights reserved.
//

#import "EZDViewController.h"

#import <EZDDebugServer.h>
#import <EZDClientAPM.h>
#import <EasyDebug.h>

#import "EZDRequestAgent.h"
#import "EZDOptionsExample.h"

@interface EZDViewController ()<EZDClientAPMProtocol>

@end

@implementation EZDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  debug server will run automatic.
//    [EZDDebugServer startServerWithPort:8088];
    
    //  start APM(if need)
    [EZDClientAPM startMonitoring];
    [EZDClientAPM addLogObserver:self];
    
    //  regiest options class(if need)
    [EasyDebug regiestOptions:[EZDOptionsExample class]];

    //  send request , EasyDebug shold record request in your request agent.
    [EZDRequestAgent GetWithParam:@{} url:@"http://api.map.baidu.com/telematics/v3/weather?location=Beijing&output=json&ak=5slgyqGDENN7Sy7pw29IUvrZ" callback:^(BOOL result, NSDictionary * _Nonnull data, NSError * _Nonnull error) {
        
    }];
    
    //  Simulate APP Stuck.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sleep(3);
    });
}

#pragma mark - EZDClientAPMProtocol
- (void)APMDidGenerateNewLogFile:(NSString *)filePath type:(EZDAPMOperationType)type{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"APM new log : \n type : %@ \n content : %@", type, fileString);
}

@end
