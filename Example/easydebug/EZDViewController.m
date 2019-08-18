//
//  EZDViewController.m
//  easydebug
//
//  Created by Song on 08/21/2018.
//  Copyright (c) 2018 Song. All rights reserved.
//

#import "EZDViewController.h"

#import "EZDRequestAgent.h"

@interface EZDViewController ()

@end

@implementation EZDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //  send request , EasyDebug shold record request in your request agent.
    [EZDRequestAgent GetWithParam:@{} url:@"https://getman.cn/echo" callback:^(BOOL result, NSDictionary * _Nonnull data, NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
