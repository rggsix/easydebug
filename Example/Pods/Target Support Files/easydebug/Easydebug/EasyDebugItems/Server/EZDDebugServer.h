//
//  EZDDebugServer.h
//  HoldCoin
//
//  Created by Song on 2019/2/20.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EZDDebugServerHandler <NSObject>

- (void)serverDidRecieveFileUploadWithPath:(NSString *)path filePath:(NSString *)filePath fileContent:(NSData *)fileContent;

@end

@interface EZDDebugServer : NSObject

+ (instancetype)startServerWithPort:(uint16_t)port;
+ (NSString *)serverURL;
+ (NSString *)uploadServerURL;
- (void)startServerWithPort:(uint16_t)port;
- (void)stopServer;

///  目前只支持监听一个上传任务，后续会优化这里
+ (void)addHandlerForUploadPath:(NSString *)uploadPath handler:(id<EZDDebugServerHandler>)handler;
+ (void)removeHandler:(id<EZDDebugServerHandler>)handler;

@end

NS_ASSUME_NONNULL_END
