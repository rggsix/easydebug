//
//  EZDAPMDeviceConsumptionMonitor.h
//  HoldCoin
//
//  Created by Song on 2019/2/12.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///  For CPU / Memory / Battery
@interface EZDAPMDeviceConsumptionMonitor : NSObject

+ (void)startMonitoring;

@end

NS_ASSUME_NONNULL_END
