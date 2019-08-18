//
//  EZDBaseURLNode.h
//  HoldCoin
//
//  Created by Song on 2019/2/26.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZDDebugServerResponse.h"
#import "EZDDebugServerHandler.h"

#if EZDDEBUG_SERVER_SUPPORT
#define EZDDebugServerRegiestNodeClass +(void)load{[EZDDebugServerHandler regiestURLNodeClass:[self class]];}
#else
#define EZDDebugServerRegiestNodeClass
#endif

@class GCDWebServerRequest;

@interface EZDBaseURLNode : NSObject

#if EZDDEBUG_SERVER_SUPPORT

+ (NSString *)nodePath;
///  default is nodePath
+ (NSString *)nodeDictPath;
+ (EZDDebugServerResponse *)respondsForGCDRequest:(GCDWebServerRequest *)request;
+ (NSString *)pathWithRequest:(GCDWebServerRequest *)request;
+ (NSBundle *)baseHTMLBundle;
+ (kEZDHTMLContentType)contentTypeWithURL:(NSURL *)url;

#endif

@end
