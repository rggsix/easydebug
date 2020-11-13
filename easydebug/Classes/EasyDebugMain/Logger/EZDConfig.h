//
//  EZDConfig.h
//  HoldCoin
//
//  Created by Song on 2018/10/17.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDConfig : NSObject

/**
 @{
     kEZDNetRequestType:@"Net request",
     kEZDEventTrackType:@"Event track",
     kEZDWebviewRequestType:@"webview request",
     kEZDJSMessageType:@"js message",
     .....
 }
 */
@property (strong,nonatomic) NSDictionary *loggerDisplayNameConfig;

@end

NS_ASSUME_NONNULL_END
