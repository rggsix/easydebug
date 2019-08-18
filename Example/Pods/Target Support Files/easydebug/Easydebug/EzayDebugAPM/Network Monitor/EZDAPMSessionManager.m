//
//  EZDAPMSessionManager.m
//  HoldCoin
//
//  Created by Song on 2019/2/19.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMSessionManager.h"
#import "EZDURLSessionChallengeSender.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface EZDAPMSessionManager ()<NSURLSessionDelegate>

@property (strong,nonatomic) NSLock *lock;
@property (strong,nonatomic) NSMapTable *delegates;

@end

@implementation EZDAPMSessionManager

+ (instancetype)shareManager{
    static EZDAPMSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        manager.sessionQueue = [[NSOperationQueue alloc] init];
        manager.sessionQueue.maxConcurrentOperationCount = 1;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager delegateQueue:manager.sessionQueue];
        
        manager.lock = [NSLock new];
        manager.lock.name = @"com.easydebug.EZDAPMSessionManager.session.name";
        
        manager.delegates = [NSMapTable strongToWeakObjectsMapTable];
    });
    return manager;
}

+ (void)addSessionDelegate:(id<NSURLSessionDelegate>)delegate forTask:(nonnull NSURLSessionTask *)task{
    if (!delegate || !task) return;
    EZDAPMSessionManager *manager = [self shareManager];
    [manager.lock lock];
    [manager.delegates setObject:delegate forKey:
     @(task.taskIdentifier)];
    [manager.lock unlock];
}

+ (void)removeSessionDelegateForTask:(NSURLSessionTask *)task{
    EZDAPMSessionManager *manager = [self shareManager];
    [manager.lock lock];
    [manager.delegates removeObjectForKey:@(task.taskIdentifier)];
    [manager.lock unlock];
}

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDelegate>)delegate{
    NSURLSessionDataTask *task = [[[EZDAPMSessionManager shareManager] session] dataTaskWithRequest:request];
    [self addSessionDelegate:delegate forTask:task];
    return task;
}

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    NSURLSessionDataTask *task = [[EZDAPMSessionManager shareManager].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        !completionHandler ?: completionHandler(data,response,error);
    }];
    return task;
}

- (bool)sessiontask:(NSURLSessionTask *)task checkIfDelegateHandleDelegateFunc:(SEL)sel withObject:(id)obj1 object:(id)obj2{
    id delegate = [self.delegates objectForKey:@(task.taskIdentifier)];
    if (![delegate respondsToSelector:sel]) return false;
    ((void(*)(id,SEL,id,id,id))objc_msgSend)(delegate,sel,self.session,obj1,obj2);
    return true;
}

- (bool)sessiontask:(NSURLSessionTask *)task checkIfDelegateHandleDelegateFunc:(SEL)sel withObject:(id)obj1 object:(id)obj2 object:(id)obj3{
    id delegate = [self.delegates objectForKey:@(task.taskIdentifier)];
    if (![delegate respondsToSelector:sel]) return false;
    ((void(*)(id,SEL,id,id,id,id))objc_msgSend)(delegate,sel,self.session,obj1,obj2,obj3);
    return true;
}

- (bool)sessiontask:(NSURLSessionTask *)task checkIfDelegateHandleDelegateFunc:(SEL)sel withObject:(id)obj1 object:(id)obj2 object:(id)obj3 object:(id)obj4{
    id delegate = [self.delegates objectForKey:@(task.taskIdentifier)];
    if (![delegate respondsToSelector:sel]) return false;
    ((void(*)(id,SEL,id,id,id,id,id))objc_msgSend)(delegate,sel,self.session,obj1,obj2,obj3,obj4);
    return true;
}

#pragma mark - task delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self sessiontask:task checkIfDelegateHandleDelegateFunc:@selector(URLSession:task:didCompleteWithError:) withObject:task object:error];
    [EZDAPMSessionManager removeSessionDelegateForTask:task];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    bool ret = [self sessiontask:dataTask checkIfDelegateHandleDelegateFunc:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:) withObject:dataTask object:response object:[completionHandler copy]];
    
    ret ?: completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self sessiontask:dataTask checkIfDelegateHandleDelegateFunc:@selector(URLSession:dataTask:didReceiveData:) withObject:dataTask object:data];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    bool ret = [self sessiontask:task checkIfDelegateHandleDelegateFunc:@selector(URLSession:task:didReceiveChallenge:completionHandler:) withObject:task object:challenge object:[completionHandler copy]];

    if (ret) return;
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    bool ret = [self sessiontask:task checkIfDelegateHandleDelegateFunc:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:) withObject:task object:response object:request object:[completionHandler copy]];

    ret ?: completionHandler(request);
}

@end
