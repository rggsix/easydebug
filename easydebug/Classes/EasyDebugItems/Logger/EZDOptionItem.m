//
//  EZDOptionItem.m
//  HoldCoin
//
//  Created by Song on 2018/10/20.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDOptionItem.h"

@implementation EZDOptionItem

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        self.title = title;
    }
    return self;
}

@end



@implementation EZDOptionNormalItem

@end



@implementation EZDOptionAlertItem

- (instancetype)initWithTitle:(NSString *)title messageString:(NSString *)messageString{
    if (self = [super initWithTitle:title]) {
        self.itemType = EZDOperationItemTypeAlert;
        self.messageString = messageString;
    }
    return self;
}

@end



@implementation EZDOptionSwitchItem

- (instancetype)initWithTitle:(NSString *)title isOn:(BOOL)isOn{
    if (self = [super initWithTitle:title]) {
        self.itemType = EZDOperationItemTypeSwitch;
        self.isOn = isOn;
    }
    return self;
}

@end



@implementation EZDOptionPikerItem

- (instancetype)initWithTitle:(NSString *)title pickerOptions:(NSArray<NSString *> *)pickerOptions{
    if (self = [super initWithTitle:title]) {
        self.itemType = EZDOperationItemTypePicker;
        self.pickerOptions = pickerOptions;
    }
    return self;
}

@end
