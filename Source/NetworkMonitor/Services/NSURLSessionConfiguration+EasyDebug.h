//
//  NSURLSessionManager+EasyDebug.h
//  EasyDebug
//
//  Created by songheng on 2020/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionConfiguration (EasyDebug)

+ (void)dg_hookDefaultSessionConfiguration;

@end

NS_ASSUME_NONNULL_END
