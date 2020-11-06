//
//  NSURLRequest+EZDAddition.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/6.
//  Copyright © 2020 Song. All rights reserved.
//

#import "NSURLRequest+EZDAddition.h"

#import "EZDDefine.h"

@implementation NSURLRequest (EZDAddition)

- (NSURLRequest *)ezd_getPostRequestWithBody {
    return [[self ezd_getMutablePostRequestWithBody] copy];
}

- (NSMutableURLRequest *)ezd_getMutablePostRequestWithBody {
    NSMutableURLRequest *mtbR = [self mutableCopy];
    BOOL needConvert = [mtbR.HTTPMethod isEqual:@"POST"] && !self.HTTPBody;
    if (needConvert) {
        NSInteger maxLen = 1024;
        uint8_t data[maxLen];
        NSInputStream *stream = self.HTTPBodyStream;
        NSMutableData *HTTPBody = [NSMutableData new];
        [stream open];
        BOOL end = NO;
        while (!end) {
            NSInteger bytes = [stream read:data maxLength:maxLen];
            if (!bytes) { // end
                end = YES;
            } else if (bytes == -1) { // error
                NSString *msg = [NSString stringWithFormat:@"POST Request body read error:%@", self];
                EZDLog(msg);
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
