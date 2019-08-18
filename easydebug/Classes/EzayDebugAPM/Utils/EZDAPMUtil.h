//
//  EZDAPMUtil.h
//  HoldCoin
//
//  Created by Song on 2019/1/25.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDAPMUtil : NSObject

///  手机型号
@property (nonatomic,copy) NSString *phoneType;
///  iOS 系统版本
@property (nonatomic,copy) NSString *osVersion;
///  IDFA
@property (nonatomic,copy) NSString *mIDFA;

@property (nonatomic,copy) NSString *processName;
@property (nonatomic,copy) NSString *processID;

///  当前正在显示的Controller Class Name
@property (strong,nonatomic) NSString *currentVCName;
@property (nonatomic,copy) NSString *lastVCName;

///  App 运行时长
@property (nonatomic,assign) NSTimeInterval launchedTime;
///  当前页面停留时长
@property (nonatomic,assign) NSTimeInterval currentVCStayTime;

@property (nonatomic,copy) NSString *bundleID;
@property (nonatomic,copy) NSString *appVersion;
@property (nonatomic,copy) NSString *appBuildVersion;
///  appVersion (appBuildVersion)
@property (nonatomic,copy) NSString *appVersionStr;

@property (nonatomic,copy) NSString *crashFilePath;

+ (instancetype)shareInstance;


+ (float)cpuUsage;
+ (int64_t)memoryUsage;
+ (CGFloat)getBatteryQuantity;
+ (long long)getAvailableMemorySize;
+ (long long)getTotalDiskSize;
+ (long long)getAvailableDiskSize;
+ (NSString *)fileSizeToString:(unsigned long long)fileSize;
+ (NSString *)getNetworkState;

@end

NS_ASSUME_NONNULL_END
