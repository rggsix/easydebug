//
//  EZDAPMSessionManager.h
//  HoldCoin
//
//  Created by Song on 2019/2/19.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDAPMSessionManager : NSObject

@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSOperationQueue *sessionQueue;

+ (instancetype)shareManager;
+ (void)addSessionDelegate:(id<NSURLSessionDelegate>)delegate forTask:(NSURLSessionTask *)task;
+ (void)removeSessionDelegateForTask:(NSURLSessionTask *)task;
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDelegate>)delegate;
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
