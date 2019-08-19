//
//  EZDAPMURLSchemeHandler.m
//  HoldCoin
//
//  Created by Song on 2019/2/18.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMURLSchemeHandler.h"
#import "EZDDefine.h"
#import "EZDAPMHooker.h"
#import "EZDAPMSessionManager.h"

#import "NSObject+EZDAddition.h"

#if defined(__IPHONE_11_0) && EZD_APM
#import <WebKit/WebKit.h>

#define EZDAPMDebugHost @"www.rgg6.com"

API_AVAILABLE(ios(11.0))
@interface EZDAPMURLSchemeHandler (EZDAPMHook) <WKURLSchemeHandler>

@end

@implementation EZDAPMURLSchemeHandler

+ (void)startMonitoring{
    [EZDAPMHooker exchangeOriginMethod:NSSelectorFromString(@"initWithFrame:configuration:") newMethod:NSSelectorFromString(@"ezd_initWithFrame:configuration:") mclass:[WKWebView class]];
}

- (instancetype)init{
    if (self = [super init]) {
        self.tasks = [NSMutableArray array];
        self.stopedSchemaTask = [NSMutableArray array];
    }
    return self;
}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)){
    if (!urlSchemeTask.request) return;
    
    bool ret = [self checkIfIsDebugReuqest:urlSchemeTask];
    if (ret) return;
    
    NSMutableURLRequest *mrequest = [urlSchemeTask.request mutableCopy];
    
    if ([[NSURLProtocol propertyForKey:EZDAPMURLProtocolHandledKey inRequest:mrequest] boolValue]) return;
    [NSURLProtocol setProperty:@(YES) forKey:EZDAPMURLProtocolHandledKey inRequest:mrequest];
//    NSLog(@"被拦截的wk url = %@ , self : %@",urlSchemeTask.request.URL.absoluteString,self);
    
    @EZDWeakObj(self);
    NSURLSessionTask *task = nil;
    @EZDWeakObj(task);
//    NSLog(@"%@ ~--> start , task : %@",urlSchemeTask,task);
    task = [EZDAPMSessionManager dataTaskWithRequest:mrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@ ~--> stoped %s, task : %@",urlSchemeTask,"dataTaskWithRequest",task);
        
        [selfWeak.tasks removeObject:taskWeak];
        if ([self.stopedSchemaTask containsObject:urlSchemeTask]) {
            [self.stopedSchemaTask removeObject:urlSchemeTask];
            return;
        }
        
        if (error) {
            [urlSchemeTask didFailWithError:error];
        } else {
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];
            @try {
                [urlSchemeTask didFinish];
            }
            @catch (NSException *exception) {

            }
        }
    }];
    if (!task) {
        [urlSchemeTask didFailWithError:[NSError new]];
        return;
    }
    [self.tasks addObject:task];
    [task resume];
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)){
    if (!urlSchemeTask) return;
    [self.stopedSchemaTask addObject:urlSchemeTask];
//    NSLog(@"%@ ~--> stoped %s, task: %@",urlSchemeTask,__func__,nil);
}

- (bool)checkIfIsDebugReuqest:(id<WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)){
    if ([urlSchemeTask.request.URL.host isEqualToString:EZDAPMDebugHost]) {
        NSLog(@"webview debugger : %@",urlSchemeTask.request.URL.pathComponents);
        [urlSchemeTask didFailWithError:[NSError new]];
        return true;
    }
    return false;
}

@end

@implementation WKWebView (EZDAPMHook)

- (instancetype)ezd_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)config{
//    NSString *method = @"_urlSchemeHandlers";
//    NSData *data = [method dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//    char *bs = malloc(sizeof(char) * data.length);
//    memcpy(bs, data.bytes, data.length);
//    for (int i = 0 ; i< data.length; i++) {
//        char c = bs[i] ^ 0x2;
//        printf("0x%2x,",c);
//    }
    
    unsigned char selByte[] = {0x5d,0x77,0x70,0x6e,0x51,0x61,0x6a,0x67,0x6f,0x67,0x4a,0x63,0x6c,0x66,0x6e,0x67,0x70,0x71};
    char sel[19] = {0};
    for (int i = 0; i< sizeof(selByte); i++) {
        char b = selByte[i] ^ 0x2;
        sel[i] = b;
    }
    sel[18] = '\0';
    NSString *selStr = [NSString stringWithCString:sel encoding:NSUTF8StringEncoding];
    
    EZDAPMURLSchemeHandler *handler = [EZDAPMURLSchemeHandler new];
//    BOOL hadProp = [config respondsToSelector:@selector(_urlSchemeHandlers)];
    BOOL hadProp = [config respondsToSelector:NSSelectorFromString(selStr)];
    if (hadProp) {
        NSMutableDictionary *handlers = [config valueForKey:selStr];
//        NSMutableDictionary *handlers = [config valueForKey:@"_urlSchemeHandlers"];
        handlers[@"http"] = handler;
        handlers[@"https"] = handler;
        handlers[@"file"] = handler;
        handlers[@"ezd"] = handler;
    }
    
    id _self = [self ezd_initWithFrame:frame configuration:config];
    !hadProp ?: [_self addErrorListener];
    
    [config ezd_printAllPropertys];
    
//    auto pageCfg = [config performSelector:@selector(_pageConfiguration)];
//
//    [config setURLSchemeHandler:handler forURLScheme:@"http"];
    
    return _self;
}

- (void)addErrorListener{
    // These request won't send out, just for js error message record.
    WKUserScript *us = [[WKUserScript alloc] initWithSource:
                        @"function sendEZDError(url) {\
                            var r = new XMLHttpRequest();\
                            r.open('GET',url,true);\
                            r.send();\
                        }\
                        window.onerror = function(errorMessage, scriptURI, lineNo, columnNo, error) {\
                            sendEZDError('https://www.rgg6.com/error/onerror?type=error&errmsg='+errorMessage+'&error='+error+'scriptURI='+scriptURI+'location='+lineNo+':'+columnNo);\
                        };\
//                        window.addEventListener('error', event => {\
//                            sendEZDError('https://www.rgg6.com/error/addEventListener_error?type=error&content='+event.target);\
//                        });\
                        window.addEventListener('unhandledrejection', event => {\
                            sendEZDError('https://www.rgg6.com/error/addEventListener_unhandledrejection?type=error&content='+event.target);\
                        });\
                        window.console.error = function () {\
                            sendEZDError('https://www.rgg6.com/error/console_error?type=error&content='+JSON.stringify(arguments));\
                            consoleError && consoleError.apply(window, arguments);\
                        };" injectionTime:(WKUserScriptInjectionTimeAtDocumentStart) forMainFrameOnly:false];
    [self.configuration.userContentController addUserScript:us];
}

@end

#endif
