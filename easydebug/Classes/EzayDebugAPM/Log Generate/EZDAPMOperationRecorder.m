//
//  EZDAPMOperationRecorder.m
//  HoldCoin
//
//  Created by Song on 2019/2/12.
//  Copyright © 2019 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDAPMOperationRecorder.h"
#import "EZDDefine.h"

#define EZDAPMOperationRecorderIns [EZDAPMOperationRecorder shareInstance]

static const int EZDAPMMaxOperationPathCount = 100;

@interface EZDAPMOperationRecorder()

@property (copy,nonatomic) NSString *currentOperationPathInfo;
@property (strong,nonatomic) NSMutableArray<NSString *> *operations;
@property (assign,nonatomic) bool operationPathModified;
@property (strong,nonatomic) NSLock *operationInfoLock;

@end

@implementation EZDAPMOperationRecorder

+ (instancetype)shareInstance{
    static EZDAPMOperationRecorder *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [EZDAPMOperationRecorder new];
        ins.operations = [[NSMutableArray alloc] initWithCapacity:EZDAPMMaxOperationPathCount*1.2];
        ins.operationInfoLock = [[NSLock alloc] init];
    });
    return ins;
}

+ (void)recordOperation:(NSString *)operationElementName operationType:(EZDAPMOperationType)operationType filePath:(nonnull NSString *)filePath{
    EZDAPMOperationRecorder *ins = EZDAPMOperationRecorderIns;
    [ins.operationInfoLock lock];
    ins.operationPathModified = true;
    [ins.operations addObject:[NSString stringWithFormat:@"%@ -> %@",operationType,operationElementName]];
//    NSLog(@"Operation recorded : %@",ins.operations.lastObject);
    if (ins.operations.count > EZDAPMMaxOperationPathCount) {
        [ins.operations removeObjectsInRange:NSMakeRange(0, ins.operations.count - EZDAPMMaxOperationPathCount)];
    }
    
    if ([EZD_NotNullString(filePath) length]
        && [ins.delegate respondsToSelector:@selector(APMOperationRecorderDidRecordNewLog:filePath:)]) {
        [ins.delegate APMOperationRecorderDidRecordNewLog:operationType filePath:filePath];
    }
    [ins.operationInfoLock unlock];
}

+ (void)generateOperationPathIfNeed{
    EZDAPMOperationRecorder *ins = EZDAPMOperationRecorderIns;
    [ins.operationInfoLock lock];
    if ([ins operationPathModified]) {
        ins.currentOperationPathInfo = [ins.operations componentsJoinedByString:@"\n"] ;
        ins.operationPathModified = false;
    }
    [ins.operationInfoLock unlock];
}

+ (NSString *)currentOperationPathInfo{
    [EZDAPMOperationRecorder generateOperationPathIfNeed];
    return EZDAPMOperationRecorderIns.currentOperationPathInfo;
}

@end
