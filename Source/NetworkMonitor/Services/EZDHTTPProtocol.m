//
//  EZDHTTPProtocol.m
// 

#import "EZDHTTPProtocol.h"
#import <objc/runtime.h>
#import "EasyDebug.h"
#import "EZDSessionManager.h"
#import "EZDLogManager+NetworkMonitor.h"
#import "EZDNetworkMonitor.h"


static NSString * _Nonnull const DebugURLProtocolHandledKey = @"DebugURLProtocolHandledKey";

@interface EZDHTTPProtocol ()<NSURLSessionTaskDelegate>

@property(nonatomic,strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *mutableData;

@end

@implementation EZDHTTPProtocol

+ (void)registerSelf {
    [NSURLProtocol registerClass:[EZDHTTPProtocol class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if (!EasyDebug.shared.isOn) return NO;
    
    if ([[NSURLProtocol propertyForKey:DebugURLProtocolHandledKey inRequest:request] boolValue]) {
        return false;
    }

    return YES;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task{
    if (!EasyDebug.shared.isOn) return NO;
    //  只处理 NSURLSessionDataTask
    Class taskCls = [task class];
    BOOL notDataTask = ![taskCls isEqual:[NSURLSessionDataTask class]];
    BOOL notLocalDataTask = ![taskCls isEqual:NSClassFromString(@"__NSCFLocalDataTask")];
    if (notDataTask && notLocalDataTask) {
        return NO;
    }
    
    return [self canInitWithRequest:task.currentRequest];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    if (!EasyDebug.shared.isOn) return request;

    NSMutableURLRequest *nrequest = [self dg_mutablePostRequestBodyWithRequest:request];
    return nrequest;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}


- (void)startLoading {
    NSMutableURLRequest *mrequest = [self.request mutableCopy];

    [NSURLProtocol setProperty:@(YES) forKey:DebugURLProtocolHandledKey inRequest:mrequest];

    self.mutableData = [NSMutableData data];
    self.task = [EZDSessionManager.sharedManager dataTaskWithRequest:mrequest delegate:self];
    [self.task resume];
}

- (void)stopLoading{
    if (self.task) {
        [self.task cancel];
        self.task  = nil;
        self.mutableData = nil;
    }
}

#pragma mark - task delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //  网络请求流程已经结束， 开始记录结果
    //  尝试获取request的body.
    NSData *requestBody = self.request.HTTPBody;
    requestBody = requestBody ? requestBody : [NSData data];
    id content = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
    NSString *responseStr = [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
    
    //  记录流量
    EZDNetworkMonitor.shared.dataFlowCount += requestBody.length + self.mutableData.length;
    
    //  没有response，记录一下status code
    if (!responseStr.length) {
        if (responseStr && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            responseStr = [NSString stringWithFormat:@"No response data.[status code:%ld]", [(NSHTTPURLResponse *)task.response statusCode]];
        } else if (error != nil) {
            responseStr = [NSString stringWithFormat:@"%@", error.localizedDescription];
        } else {
            responseStr = @"Null response.";
        }
    }
    //  URL可能被其他NSURLProtocol修改，用task.currentRequest获取真正请求的URL
    NSMutableURLRequest *curRequest = [self.request mutableCopy];
    curRequest.URL = task.currentRequest.URL;
    BOOL isIgnore = false;
    NSArray *ignoreList = [EZDNetworkMonitor.shared.ignoreUrlList copy];
    for(NSString *host in ignoreList){
        if([curRequest.URL.absoluteString containsString:host]){
            isIgnore = true;
        }
    }
    if(!isIgnore){
        [EZDLogManager.shared recordNetRequestWithRequest:curRequest
                                                    content:content
                                                   response:responseStr
                                                      error:error];
    }    
    if (error) { //  失败
        [self.client URLProtocol:self didFailWithError:error];
    } else { //  成功
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.mutableData appendData:data];
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLAuthenticationChallenge* challengeWrapper = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:[[DebugURLSessionChallengeSender alloc] initWithSessionCompletionHandler:completionHandler]];
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challengeWrapper];
    
    BOOL isServChallenge = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    NSURLSessionAuthChallengeDisposition disposition = isServChallenge ? NSURLSessionAuthChallengeUseCredential : NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    BOOL isServChallenge = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    NSURLSessionAuthChallengeDisposition disposition = isServChallenge ? NSURLSessionAuthChallengeUseCredential : NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

#pragma mark - util func
+ (NSMutableURLRequest *)dg_mutablePostRequestBodyWithRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mtbR = [request mutableCopy];
    BOOL emptyBody = ![request.HTTPBody length];
    BOOL notGET = ![mtbR.HTTPMethod isEqual:@"GET"];
    if (notGET && emptyBody) {
        NSInteger maxLen = 1024;
        uint8_t data[maxLen];
        NSInputStream *stream = request.HTTPBodyStream;
        NSMutableData *HTTPBody = [NSMutableData new];
        [stream open];
        BOOL end = NO;
        while (!end) {
            NSInteger bytes = [stream read:data maxLength:maxLen];
            if (!bytes) { // end
                end = YES;
            } else if (bytes == -1) { // error
                NSString *msg = [NSString stringWithFormat:@"POST Request body read error:%@", request];
                [EasyDebug logConsole:@"[EasyDebug] %@", msg];
                end = YES;
            } else if (!stream.streamError) {
                [HTTPBody appendBytes:(void *)data length:bytes];
            }
        }
        mtbR.HTTPBody = [HTTPBody copy];
        [stream close];
    }
    return mtbR;
}

@end

