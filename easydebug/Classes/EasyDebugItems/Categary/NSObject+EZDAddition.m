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
        NSDictionary *dictObj = [NSObject getObjectInternal:self];
        desStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictObj options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        
    } @finally {
        return desStr;
    }
}

+ (bool)isSubClassAndNotItSelf:(Class)cls{
    return [self isSubclassOfClass:cls] && ![self isEqual:cls];
}

+ (NSDictionary*)getObjectData:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++) {
        objc_property_t prop = props[i];

        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil) {
            value = @"";
        } else if ([obj isKindOfClass:[NSString class]]
                 || [obj isKindOfClass:[NSNumber class]]
                 || [obj isKindOfClass:[NSNull class]]
                 || [obj isKindOfClass:[NSArray class]]
                 || [obj isKindOfClass:[NSDictionary class]]){
            value = [self getObjectInternal:value];
        } else {
            value = [self getObjectData:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+ (id)getObjectInternal:(id)obj {
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }

    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }

    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

@end
