//
//  NSURLRequest+EZDAddition.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/6.
//  Copyright © 2020 Song. All rights reserved.
//

#import "NSURLRequest+EZDAddition.h"

#import "EZDDefine.h"
#import "EZDAPMHooker.h"

#import <objc/runtime.h>

@implementation NSURLRequest (EZDAddition)

#pragma mark - public
- (NSMutableURLRequest *)ezd_mutableCopy {
    NSMutableURLRequest *nrequest = [self mutableCopy];
    nrequest.ezd_fromEZDAPM = self.ezd_fromEZDAPM;
    nrequest.ezd_fromNative = self.ezd_fromNative;
    return nrequest;
}

- (NSMutableURLRequest *)ezd_getMutablePostRequestWithBody {
    NSMutableURLRequest *mtbR = [self mutableCopy];
    mtbR.ezd_fromNative = self.ezd_fromNative;
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

#pragma mark - getter && setter
- (BOOL)ezd_fromNative {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEzd_fromNative:(BOOL)ezd_fromNative {
    objc_setAssociatedObject(self, @selector(ezd_fromNative), @(ezd_fromNative), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ezd_fromEZDAPM {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEzd_fromEZDAPM:(BOOL)ezd_fromEZDAPM {
    objc_setAssociatedObject(self, @selector(ezd_fromEZDAPM), @(ezd_fromEZDAPM), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
