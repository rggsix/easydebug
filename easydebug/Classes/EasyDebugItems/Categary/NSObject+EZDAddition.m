//
//  NSObject+EZDAddition.m
//  HoldCoin
//
//  Created by Song on 2018/10/18.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "NSObject+EZDAddition.h"
#import "EZDDefine.h"
#import <objc/message.h>

@implementation NSObject (EZDDescription)

- (void)ezd_printAllPropertys{
    unsigned int count;
    const char *clasName = object_getClassName(self);
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%s: %p>:[ \n",clasName, self];
    Class clas = NSClassFromString([NSString stringWithCString:clasName encoding:NSUTF8StringEncoding]);
    Ivar *ivars = class_copyIvarList(clas, &count);
    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *type = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
            NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            id value = [self valueForKey:key];
            if ([type isEqualToString:@"B"]) {
                value = (value == 0 ? @"NO" : @"YES");
            }
            [string appendFormat:@"\t%@: %@\n",key, value];
        }
    }
    [string appendFormat:@"]"];
    NSLog(@"%@ porperty list : %@",self,string);
}

- (NSString *)ezd_description{
    NSString *jsonStr = [self ezd_JSONString];
    if (!jsonStr.length) {
        jsonStr = [self description];
    }
    return jsonStr;
}

- (NSString *)ezd_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    } else if ([[self class] isSubclassOfClass:[NSNumber class]]){
        return [self description];
    } else if ([self isKindOfClass:[NSError class]]) {
        return [self description];
    } 
    
    NSString *desStr = [self description];
    @try {
        desStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        
    } @finally {
        return desStr;
    }
}

+ (bool)isSubClassAndNotItSelf:(Class)cls{
    return [self isSubclassOfClass:cls] && ![self isEqual:cls];
}

@end
