//
//  EZDAPMOperationRecorder.h
//  HoldCoin
//
//  Created by Song on 2019/2/12.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * EZDAPMOperationType NS_EXTENSIBLE_STRING_ENUM;
static EZDAPMOperationType const EZDAPMOperationClick = @"Click";
static EZDAPMOperationType const EZDAPMOperationPageAppear = @"PageAppear";
static EZDAPMOperationType const EZDAPMOperationGesBegin = @"GestureBegin";
static EZDAPMOperationType const EZDAPMOperationTableViewSelect = @"TableViewSelect";
static EZDAPMOperationType const EZDAPMOperationCollectionViewSelect = @"CollectionViewSelect";

//  Device States
static EZDAPMOperationType const EZDAPMOperationStuck = @"DeviceStuck";
static EZDAPMOperationType const EZDAPMOperationCPUHeigh = @"CPUHeighUsage";
static EZDAPMOperationType const EZDAPMOperationMemoryHeigh = @"MemoryHeighUsage";
static EZDAPMOperationType const EZDAPMOperationBatteryLv = @"BatteryLevelChange";
static EZDAPMOperationType const EZDAPMOperationBatteryState = @"BatteryStateChange";

@interface EZDAPMOperationRecorder : NSObject

+ (instancetype)shareInstance;
+ (NSString *)currentOperationPathInfo;
+ (void)recordOperation:(NSString *)operationElementName operationType:(EZDAPMOperationType)operationType;

@end

NS_ASSUME_NONNULL_END
