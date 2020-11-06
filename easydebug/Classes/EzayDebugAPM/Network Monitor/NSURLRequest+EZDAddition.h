//
//  NSURLRequest+EZDAddition.h
//  easydebug_Example
//
//  Created by qingting on 2020/11/6.
//  Copyright © 2020 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (EZDAddition)

- (NSURLRequest *)ezd_getPostRequestWithBody;

@end

NS_ASSUME_NONNULL_END
