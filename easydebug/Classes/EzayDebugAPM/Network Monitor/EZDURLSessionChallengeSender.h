//
//  EZDURLSessionChallengeSender.h
//  HoldCoin
//
//  Created by Song on 2019/2/20.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDURLSessionChallengeSender : NSObject <NSURLAuthenticationChallengeSender>

- (instancetype)initWithSessionCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

@end

NS_ASSUME_NONNULL_END
