//
//  EZDOptionItem.h
//  HoldCoin
//
//  Created by Song on 2018/10/20.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EZDOperationItemTypeNormal,
    EZDOperationItemTypeAlert,
    EZDOperationItemTypeSwitch,
    EZDOperationItemTypePicker,
} EZDOperationItemType;

@interface EZDOptionItem : NSObject

@property (nonatomic,assign) EZDOperationItemType itemType;
@property (nonatomic,copy) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end



@interface EZDOptionNormalItem : EZDOptionItem

@end



@interface EZDOptionAlertItem : EZDOptionItem

///  the message of alertView
@property (nonatomic,copy) NSString *messageString;

@property (nonatomic,copy) NSString *alertInputString;
/// 0 for cancle , 1 for confirm
@property (nonatomic,assign) BOOL isConfirm;

- (instancetype)initWithTitle:(NSString *)title messageString:(NSString *)messageString;

@end



@interface EZDOptionSwitchItem : EZDOptionItem

@property (nonatomic,assign) BOOL isOn;
- (instancetype)initWithTitle:(NSString *)title isOn:(BOOL)isOn;

@end



@interface EZDOptionPikerItem : EZDOptionItem

@property (strong,nonatomic) NSArray<NSString *> *pickerOptions;
@property (nonatomic,copy) NSString *seletedOption;
- (instancetype)initWithTitle:(NSString *)title pickerOptions:(NSArray<NSString *> *)pickerOptions;

@end
