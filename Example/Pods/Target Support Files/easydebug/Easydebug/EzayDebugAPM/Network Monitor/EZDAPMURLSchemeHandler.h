//
//  EZDAPMURLSchemeHandler.h
//  HoldCoin
//
//  Created by Song on 2019/2/18.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __IPHONE_11_0

@interface EZDAPMURLSchemeHandler : NSObject

@property (strong,nonatomic) NSMutableArray<NSURLSessionTask *> *tasks;
@property (strong,nonatomic) NSMutableArray *stopedSchemaTask;

+ (void)startMonitoring;

@end

#endif
