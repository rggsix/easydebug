//
//  EZDLogDisplayCell.h
//  HoldCoin
//
//  Created by Song on 2018/10/8.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZDLoggerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogDisplayCell : UITableViewCell

@property (nonatomic,assign) NSInteger rowOfCell;
@property (strong,nonatomic) EZDLoggerModel *logModel;

@end

NS_ASSUME_NONNULL_END
