//
//  EZDOnceStartModel.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogModel : NSObject

@property (nonatomic, assign)   NSInteger logId;
@property (nonatomic, copy)     NSString *tag;
@property (nonatomic, copy, readonly) NSString *abstractString;
@property (nonatomic, strong)   NSDictionary *contentDic;
//  YYYY-MM-dd HH:mm:ss
@property (nonatomic,copy)      NSString *dateDes;
@property (nonatomic,assign)    NSTimeInterval timeStamp;

- (instancetype)initWithTag:(NSString *_Nullable)tag
                 contentDic:(NSDictionary *)contentDic
                  timeStamp:(NSTimeInterval)timeStamp;

@end

NS_ASSUME_NONNULL_END
