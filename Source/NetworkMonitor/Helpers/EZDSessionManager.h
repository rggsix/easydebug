//
//  EZDSessionManager.h
//  EasyDebug
//
//  Created by songheng on 2020/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugURLSessionChallengeSender : NSObject <NSURLAuthenticationChallengeSender>

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

@end

@interface EZDSessionManager : NSObject

@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSOperationQueue *sessionQueue;

+ (instancetype)sharedManager;
- (void)addSessionDelegate:(id<NSURLSessionDelegate>)delegate forTask:(NSURLSessionTask *)task;
- (void)removeSessionDelegateForTask:(NSURLSessionTask *)task;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDelegate>)delegate;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
