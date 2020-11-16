//
//  EZDTestWebViewController.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/16.
//  Copyright © 2020 Song. All rights reserved.
//

#import "EZDTestWebViewController.h"

#import <WebKit/WebKit.h>

@interface EZDTestWebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webview;

@end

@implementation EZDTestWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webview];
    self.webview.navigationDelegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]];
    [self.webview loadRequest:request];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

@end
