//
//  NSURLRequest+EZDAddition.h
//  easydebug_Example
//
//  Created by qingting on 2020/11/6.
//  Copyright © 2020 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kEZDURLRequestFromNative = @"kEZDURLRequestFromNative";

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (EZDAddition)

///  The request begin with AFN/NSURLSession or not.
@property (nonatomic, assign) BOOL ezd_fromNative;
///  The request if from EZDAPM.
@property (nonatomic, assign) BOOL ezd_fromEZDAPM;

- (NSMutableURLRequest *)ezd_mutableCopy;
- (NSMutableURLRequest *)ezd_getMutablePostRequestWithBody;

@end

NS_ASSUME_NONNULL_END
