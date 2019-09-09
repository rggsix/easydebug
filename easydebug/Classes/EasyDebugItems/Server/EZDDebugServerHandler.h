//
//  EZDDebugServerHandler.h
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZDDebugServerResponse.h"

#if EZDDEBUG_SERVER_SUPPORT
#import <GCDWebServerRequest.h>
#endif


#ifndef EZDDebugServerMaxPathDeep
    #define EZDDebugServerMaxPathDeep 10
#endif

@interface EZDDebugServerHandler : NSObject

+ (void)regiestURLNodeClass:(Class)urlNodeClass;

+ (EZDDebugServerResponse *)responseWithMethod:(NSString *)method GCDRequest:(GCDWebServerRequest *)request;

@end
