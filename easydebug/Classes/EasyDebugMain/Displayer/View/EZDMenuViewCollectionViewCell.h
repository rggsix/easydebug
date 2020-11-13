//
//  EZDMenuViewCollectionViewCell.h
//  easydebug_Example
//
//  Created by qingting on 2020/11/13.
//  Copyright © 2020 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EZDMenuInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDMenuViewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) EZDMenuInfoModel *model;

@end

NS_ASSUME_NONNULL_END
