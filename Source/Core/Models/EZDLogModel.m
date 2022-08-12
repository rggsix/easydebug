//
//  EZDOnceStartModel.m
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import "EZDLogModel.h"
#import "EZDOnceStart.h"
#import "EasyDebugUtil.h"
#import "EasyDebug.h"
#import "DebugCoreCategorys.h"


@interface EZDLogModel ()

@property (nonatomic, copy, readwrite) NSString *abstractString;

@end

@implementation EZDLogModel

- (instancetype)initWithTag:(NSString *_Nullable)tag
                 contentDic:(NSDictionary *)contentDic
                  timeStamp:(NSTimeInterval)timeStamp{
    if (self = [super init]) {
        self.tag = tag;
        self.contentDic = contentDic;
        self.timeStamp = timeStamp ? timeStamp : [[NSDate date] timeIntervalSince1970];
        self.dateDes = [[NSDate dateWithTimeIntervalSince1970:self.timeStamp] dg_stringWithISOFormat];
    }
    return self;
}

- (NSString *)abstractString {
    if (!_abstractString) {
        DebugLogAbstractProvider provider = [EasyDebug.shared getAbstractProviderForTag:_tag];

        if (provider) {
            _abstractString = provider(_tag, _contentDic);
        }
        
        //  用户没有自定义，还是用内置逻辑
        if (!DGIsNotNull(_abstractString)) {
            if ([self.tag isEqualToString:kDebugNetworkLogTag]) {
                _abstractString = [self.contentDic valueForKey:@"targetURL"];
            } else {
                NSString *absStr;
                if (self.contentDic.allKeys.count) {
                    //  如果content中只有一条内容，简述直接展示这条内容的value，否则展示description
                    if (self.contentDic.allKeys.count > 1) {
                        absStr = [[self.contentDic dg_JSONDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    } else {
                        absStr = [NSString stringWithFormat:@"%@", self.contentDic.allValues.firstObject];
                    }
                }
                
                _abstractString = absStr.length ? absStr : @"[无内容Log]";
            }
        }

        _abstractString = (_abstractString.length) < 100 ? _abstractString : [_abstractString substringToIndex:99] ;
    }
    return _abstractString;
}

@end
