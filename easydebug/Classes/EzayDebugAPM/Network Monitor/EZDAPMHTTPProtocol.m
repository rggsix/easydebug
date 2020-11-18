//
//  EZDAPMHTTPProtocol.m
//  HoldCoin
//
//  Created by Song on 2019/2/14.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMHTTPProtocol.h"
#import <objc/runtime.h>

#import "EasyDebug.h"
#import "EZDAPMHooker.h"
#import "EZDDefine.h"
#import "EZDAPMSessionManager.h"
#import "EZDURLSessionChallengeSender.h"

#import "NSURLRequest+EZDAddition.h"

static BOOL kEZDWKWebViewNetworkHook = NO;

@interface NSURLSessionConfiguration (EZDAPMHook)

+ (void)setEZDURLSessionProtocolEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)configuration;

@end

@implementation NSURLSessionConfiguration (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeClassOriginMethod:@selector(defaultSessionConfiguration) newMethod:@selector(ezd_defaultSessionConfiguration) mclass:[self class]];
}

+ (NSURLSessionConfiguration *)ezd_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [self ezd_defaultSessionConfiguration];
    [self setEZDURLSessionProtocolEnabled:YES forSessionConfiguration:configuration];
    return configuration;
}

+ (void)setEZDURLSessionProtocolEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)configuration{
    if ([configuration respondsToSelector:@selector(protocolClasses)]
        && [configuration respondsToSelector:@selector(setProtocolClasses:)]) {
        
        NSMutableArray *protocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        Class protoCls = [EZDAPMHTTPProtocol class];
        if (enabled && ![protocolClasses containsObject:protoCls]) {
            [protocolClasses insertObject:protoCls atIndex:0];
        } else if (!enabled && [protocolClasses containsObject:protoCls]) {
            [protocolClasses removeObject:protoCls];
        }
        configuration.protocolClasses = protocolClasses;
    }
}

@end

@interface EZDAPMHTTPProtocol ()<NSURLSessionTaskDelegate>

@property(nonatomic,strong) NSURLSessionTask *task;

@property(nonatomic,strong) NSURLConnection *connection;

@end

@implementation EZDAPMHTTPProtocol

+ (void)setupHTTPProtocol{
    [NSURLProtocol registerClass:[EZDAPMHTTPProtocol class]];
}

+ (void)WKWebViewNetworkMonitoring:(BOOL)open {
    kEZDWKWebViewNetworkHook = open;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if (!request.ezd_fromNative && !kEZDWKWebViewNetworkHook) {
        //   未开启webview监听，不处理来自非native的请求
        return NO;
    }
    
    if ([[NSURLProtocol propertyForKey:EZDAPMURLProtocolHandledKey inRequest:request] boolValue]) {
        return false;
    }

    return YES;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task{
    task.currentRequest.ezd_fromNative = task.originalRequest.ezd_fromNative;
    return [self canInitWithRequest:task.currentRequest];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *nrequest = [request ezd_getMutablePostRequestWithBody];
    if (nrequest.ezd_fromNative) {
        [nrequest setValue:@(request.ezd_fromNative).stringValue forHTTPHeaderField:kEZDURLRequestFromNative];
    }
    return nrequest;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    //  Remove header value which added in "canonicalRequestForRequest:"
    NSMutableURLRequest *mrequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        mrequest = (NSMutableURLRequest *)request;
    } else {
        mrequest = [request mutableCopy];
    }
    request.ezd_fromNative = [request valueForHTTPHeaderField:kEZDURLRequestFromNative].boolValue;
    [mrequest setValue:nil forHTTPHeaderField:kEZDURLRequestFromNative];
    request = mrequest;
    
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}


- (void)startLoading {
    NSMutableURLRequest *mrequest = [self.request mutableCopy];
    //  把这个 request 标记为 APM 发起的request，防止新创建的task将其reuqest主动标记为fromNative
    mrequest.ezd_fromEZDAPM = YES;
    mrequest.ezd_fromNative = self.request.ezd_fromNative;

    [NSURLProtocol setProperty:@(YES) forKey:EZDAPMURLProtocolHandledKey inRequest:mrequest];

    _task = [EZDAPMSessionManager dataTaskWithRequest:mrequest delegate:self];
    [_task resume];
}

- (void)stopLoading{
    if (_task) {
        [_task cancel];
        _task  = nil;
    }
    
    if (_connection) {
        [_connection cancel];
        _connection = nil;
    }
}

#pragma mark - task delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.task = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
    //  Try to get post body.
    NSData *requestBody = self.request.HTTPBody;
    requestBody = requestBody ? requestBody : [NSData data];
    id param = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
    id response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    EZDRecordNetRequest(self.request, param, response);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLAuthenticationChallenge* challengeWrapper = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:[[EZDURLSessionChallengeSender alloc] initWithSessionCompletionHandler:completionHandler]];
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challengeWrapper];
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

@end

