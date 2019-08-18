//
//  EZDRequestAgent.h
//  easydebug_Example
//
//  Created by EDZ on 2019/8/19.
//  Copyright © 2019 Song. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDRequestAgent : AFHTTPSessionManager

+ (EZDRequestAgent *)shareAgent;

+ (NSURLSessionDataTask *)GetWithParam:(NSDictionary *)param url:(NSString *)url callback:(void(^)(BOOL result, NSDictionary *data, NSError *error))callback;

@end

NS_ASSUME_NONNULL_END
