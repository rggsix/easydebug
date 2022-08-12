//
//  EZDLogAbstractCell.h
//  EasyDebug
//
//  Created by songheng on 2020/11/25.
//

#import <UIKit/UIKit.h>
#import "EZDLogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZDLogAbstractCell : UITableViewCell

@property (strong,nonatomic) EZDLogModel *logModel;

@end

NS_ASSUME_NONNULL_END
