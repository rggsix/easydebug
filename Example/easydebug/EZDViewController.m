//
//  EZDViewController.m
//  easydebug
//
//  Created by Song on 08/21/2018.
//  Copyright (c) 2018 Song. All rights reserved.
//

#import "EZDViewController.h"

#import "EZDTestWebViewController.h"

#import "EZDDebugServer.h"
#import "EZDClientAPM.h"
#import "EasyDebug.h"

#import "EZDRequestAgent.h"
#import "EZDOptionsExample.h"

#import "NSObject+EZDAddition.h"

#import <WebKit/WebKit.h>

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
    EZDRegiestDebugOptions([EZDOptionsExample class]);
    
    [self setupUI];
    
    [self ezd_printAllMethod];
}

- (void)setupUI {
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:[self buttonWithText:@"Net request(AFN)" y:10 action:@selector(netRequestAFN)]];
    [self.view addSubview:[self buttonWithText:@"Net request(URLSession)" y:50 action:@selector(netRequestURLSession)]];
    [self.view addSubview:[self buttonWithText:@"Simulate Stuck" y:90 action:@selector(SimulateAPPStuck)]];
    [self.view addSubview:[self buttonWithText:@"WKWebView" y:130 action:@selector(goWebview)]];
}

- (UIButton *)buttonWithText:(NSString *)text y:(CGFloat)y action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button setTitle:text forState:(UIControlStateNormal)];
    button.frame = CGRectMake(40, y, 150, 25);
    button.center = CGPointMake(self.view.frame.size.width * .5, button.center.y);
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    return button;
}

#pragma mark - responsd func
- (void)netRequestAFN {
    //  send request , EasyDebug shold record request in your request agent.
    [EZDRequestAgent GetWithParam:@{@"p1":@"v1", @"p2":@"v2"} url:@"http://api.map.baidu.com/telematics/v3/weather?location=Beijing&output=json&ak=5slgyqGDENN7Sy7pw29IUvrZ" callback:^(BOOL result, NSDictionary * _Nonnull data, NSError * _Nonnull error) {
        NSLog(@"netRequestAFN : %@", data);
    }];
}




- (void)netRequestURLSession {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlstr = @"https://getman.cn/echo";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"p1":@"v1",@"p2":@{@"sp1":@"sv1"}} options:0 error:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"netRequestURLSession : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
}

- (void)SimulateAPPStuck {
    //  Simulate APP Stuck.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sleep(3);
    });
}

- (void)goWebview {
    [self.navigationController pushViewController:[EZDTestWebViewController new] animated:YES];
}

#pragma mark - EZDClientAPMProtocol
- (void)APMDidGenerateNewLogFile:(NSString *)filePath type:(EZDAPMOperationType)type{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"APM new log : \n type : %@ \n content : %@", type, fileString);
}

@end
