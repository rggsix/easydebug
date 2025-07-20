//
//  EZDSessionManager.m
//  EasyDebug
//
//  Created by songheng on 2020/12/1.
//

#import "EZDSessionManager.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface EZDSessionManager ()<NSURLSessionDelegate>

@property (strong,nonatomic) NSLock *lock;
@property (strong,nonatomic) NSMapTable *delegates;

@end

@implementation EZDSessionManager

+ (instancetype)sharedManager{
    static EZDSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sessionQueue = [[NSOperationQueue alloc] init];
        self.sessionQueue.maxConcurrentOperationCount = 1;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config
                                                     delegate:self
                                                delegateQueue:self.sessionQueue];
        
        self.lock = [NSLock new];
        self.lock.name = @"com.EasyDebug.DebugSessionManager.session.name";
        
        self.delegates = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)addSessionDelegate:(id<NSURLSessionDelegate>)delegate forTask:(nonnull NSURLSessionTask *)task{
    if (!delegate || !task) return;
    [self.lock lock];
    [self.delegates setObject:delegate forKey:
     @(task.taskIdentifier)];
    [self.lock unlock];
}

- (void)removeSessionDelegateForTask:(NSURLSessionTask *)task{
    [self.lock lock];
    [self.delegates removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDelegate>)delegate{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [self addSessionDelegate:delegate forTask:task];
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    [self removeSessionDelegateForTask:task];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    bool ret = [self sessiontask:dataTask checkIfDelegateHandleDelegateFunc:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:) withObject:dataTask object:response object:[completionHandler copy]];
    
    ret ?: completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self sessiontask:dataTask checkIfDelegateHandleDelegateFunc:@selector(URLSession:dataTask:didReceiveData:) withObject:dataTask object:data];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    BOOL isServChallenge = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    NSURLSessionAuthChallengeDisposition disposition = isServChallenge ? NSURLSessionAuthChallengeUseCredential : NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    bool ret = [self sessiontask:task checkIfDelegateHandleDelegateFunc:@selector(URLSession:task:didReceiveChallenge:completionHandler:) withObject:task object:challenge object:[completionHandler copy]];

    if (ret) return;
    
    BOOL isServChallenge = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    NSURLSessionAuthChallengeDisposition disposition = isServChallenge ? NSURLSessionAuthChallengeUseCredential : NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    bool ret = [self sessiontask:task checkIfDelegateHandleDelegateFunc:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:) withObject:task object:response object:request object:[completionHandler copy]];

    ret ?: completionHandler(request);
}

@end

@implementation DebugURLSessionChallengeSender
{
    void (^_sessionCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);
}

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if(self = [super init])
    {
        _sessionCompletionHandler = [completionHandler copy];
    }
    
    return self;
}

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
}

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    _sessionCompletionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _sessionCompletionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
}

@end
