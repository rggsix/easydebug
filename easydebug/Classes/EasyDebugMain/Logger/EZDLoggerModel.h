//
//  EZDLoggerModel.h
//  HoldCoin
//
//  Created by Song on 2018/9/30.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZDLoggerModel : NSObject

@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,copy) NSString *displayTypeName;
@property (nonatomic,copy) NSString *abstractString;
@property (strong,nonatomic) NSDictionary *parameter;
//  YYYY-MM-dd HH:mm:ss
@property (nonatomic,copy) NSString *dateDes;
@property (nonatomic,assign) NSTimeInterval timeStamp;

+ (instancetype)modelWithTypeName:(NSString *)typeName
                   abstractString:(NSString *)abstractString
                        parameter:(NSDictionary *)parameter
                        timeStamp:(NSTimeInterval)timeStamp;

@end
