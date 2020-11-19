//
//  EZDOptions.h
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EZDOptionItem.h"
#import "EZDDefine.h"

@class EZDOptionItem;

@protocol EZDOptionProtocol <NSObject>

@required
/**
 请返回Debug options的列表信息
 */
- (NSArray<EZDOptionItem *> *)optionItems;

/**
 用户对Option进行了操作，请在此代理方法中回应用户的操作。
 如：用户点击了"crash now"，则在此方法中模拟一个crash。
 这个操作是与optionItems方法中返回的列表相对应的，由你自己进行定义的。
 
 EZDOptionItem总共包含四种，也就是支持四种操作：
 Normal : 普通的cell，用途如：模拟一个crash
 Alert : 点击cell会弹出一个带输入框的弹窗，用途如：输入自定义baseURL
 Switch : 一个包含UISwictch的cell，用途如：模拟弱网(YES/NO)
 Picker : 一个选择列表，用途如：更改当前用户VIP等级
 
 你可以在这个代理方法中执行一些耗时操作，待操作完成后再调用callback(handledItem)
 
 @param optionItem 你自己在optionItems返回的item
 @param atRow indexPath.row
 @param callback 调用callback代表你已经完成了操作
 */
- (void)didOperaionOptionCell:(EZDOptionItem *)optionItem atRow:(NSInteger)row callback:(void(^)(EZDOptionItem *handledItem))callback;

@end
   
@interface EZDOptions : NSObject<EZDOptionProtocol>

@property (strong,nonatomic) NSUserDefaults *userDefaultOptions;

+ (instancetype)shareOptionInstance;

/**
 注册Debug option handler，这个类需要继承自 EZDOptions
 
 @param optionHandleClass -> 自定义的 debug option 类，自行在内部返回"optionItems"列表，并在didOperaionOptionCell:atRow:callback:中执行具体操作
 
 */
+ (void)regiestOptionInstace:(Class)optionHandleClass;

/**
 当前注册的debug option handler
 */
+ (instancetype)currentOptionInstance;

@end
