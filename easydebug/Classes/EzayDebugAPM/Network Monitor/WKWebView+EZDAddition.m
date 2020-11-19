//
//  WKWebView+EZDAddition.m
//  easydebug_Example
//
//  Created by qingting on 2020/11/17.
//  Copyright © 2020 Song. All rights reserved.
//

#import "WKWebView+EZDAddition.h"

#import "EZDAPMHooker.h"

@implementation WKWebView (EZDAddition)

#if EZD_APM
+ (void)load{
    [EZDAPMHooker exchangeOriginMethod:NSSelectorFromString(@"initWithFrame:configuration:") newMethod:NSSelectorFromString(@"ezd_initWithFrame:configuration:") mclass:[WKWebView class]];
}
#endif

- (instancetype)ezd_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)config{
#if EZD_APM
    id _self = [self ezd_initWithFrame:frame configuration:config];
    NSString *bcc1 = @"browsing";
    NSString *bcc2 = @"Context";
    NSString *bcc3 = @"Controller";

    SEL bccSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", bcc1, bcc2, bcc3]);
    if ([self respondsToSelector:bccSEL]) {
        id contextControllerCLS = [[_self valueForKey:NSStringFromSelector(bccSEL)] class];
        
        NSString *rscp1 = @"register";
        NSString *rscp2 = @"Scheme";
        NSString *rscp3 = @"ForCustom";
        NSString *rscp4 = @"Protocol:";
        SEL rscpSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", rscp1, rscp2, rscp3, rscp4]);
        if ([(id)contextControllerCLS respondsToSelector:rscpSEL]) {
            [contextControllerCLS performSelector:rscpSEL withObject:@"http"];
            [contextControllerCLS performSelector:rscpSEL withObject:@"https"];
            [contextControllerCLS performSelector:rscpSEL withObject:@"file"];
        }
    }

    return _self;
#else
    id _self = [self ezd_initWithFrame:frame configuration:config];
    return _self;
#endif
}

@end
