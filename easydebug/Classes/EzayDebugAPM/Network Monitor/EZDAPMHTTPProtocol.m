//
//  EZDAPMHTTPProtocol.m
//  HoldCoin
//
//  Created by Song on 2019/2/14.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMHTTPProtocol.h"
#import "EZDAPMHooker.h"
#import "EZDDefine.h"
#import "EZDAPMSessionManager.h"
#import "EZDURLSessionChallengeSender.h"

@interface NSURLSessionConfiguration (EZDAPMHook)

+ (void)setEZDURLSessionProtocolEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)configuration;

@end

#if EZD_APM
    #ifdef _AFNETWORKING_
@implementation AFURLSessionManager (EZDAPMHook)

+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:@selector(setSession:) newMethod:@selector(ezd_setSession:) mclass:[AFURLSessionManager class]];
}

- (void)ezd_setSession:(NSURLSession *)session{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [NSURLSessionConfiguration setEZDURLSessionProtocolEnabled:true forSessionConfiguration:configuration];
    session = [NSURLSession sessionWithConfiguration:configuration delegate:session.delegate delegateQueue:session.delegateQueue];
    [self ezd_setSession:session];
}

@end
    #endif
#endif

@implementation NSURLSessionConfiguration (EZDAPMHook)

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
    
#ifndef __IPHONE_11_0
//    Class cls = NSClassFromString(@"WKBrowsingContextController");
//    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
//    if ([cls respondsToSelector:sel]) {
//        [cls performSelector:sel withObject:@"http"];
//        [cls performSelector:sel withObject:@"https"];
//        [cls performSelector:sel withObject:@"file"];
//    }
#else
    
#endif
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if ([request.URL.absoluteString containsString:@"ihold.com"]) {// && ![request.URL.absoluteString containsString:@"v2/ws/pair_price"]
        if ([[NSURLProtocol propertyForKey:EZDAPMURLProtocolHandledKey inRequest:request] boolValue]) {
            return false;
        }
        return true;
    } else if ([request.URL.absoluteString containsString:@"/source/"]) {
        if ([[NSURLProtocol propertyForKey:EZDAPMURLProtocolHandledKey inRequest:request] boolValue]) {
            return false;
        }
        return true;
    }

    return false;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task{
    return [self canInitWithRequest:task.currentRequest];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

//
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}


- (void)startLoading {
    NSMutableURLRequest *mrequest = [self.request mutableCopy];
    
    [NSURLProtocol setProperty:@(YES) forKey:EZDAPMURLProtocolHandledKey inRequest:mrequest];
//    NSLog(@"被拦截的url = %@ , self : %@",self.request.URL.absoluteString,self);

    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
        _task = [EZDAPMSessionManager dataTaskWithRequest:mrequest delegate:self];
        [_task resume];
    } else {
        _connection = [[NSURLConnection alloc] initWithRequest:mrequest delegate:self startImmediately:YES];
    }

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

