//
//  EZDMessageHUD.m
//  HoldCoin
//
//  Created by Song on 2018/10/19.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "EZDMessageHUD.h"
#import "UIView+EZDAddition_frame.h"
#import "EZDSystemUtil.h"

@interface EZDMessageHUD ()

@property (strong,nonatomic) UILabel *messageLabel;
@property (strong,nonatomic) UIImageView *contentImageView;

@end

@implementation EZDMessageHUD

+ (instancetype)shareHUD{
    static EZDMessageHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[EZDMessageHUD alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [hud setupBaseUI];

    });
    return hud;
}

- (void)setupBaseUI{
    self.userInteractionEnabled = false;
    self.backgroundColor = [UIColor clearColor];
    self.messageLabel = [UILabel new];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.backgroundColor = [UIColor whiteColor];
    self.messageLabel.layer.borderColor = [UIColor redColor].CGColor;
    self.messageLabel.layer.borderWidth = 2;
    self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.ezd_width*.5, self.ezd_width*.5)];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    self.contentImageView.layer.cornerRadius = 8;
    self.contentImageView.layer.masksToBounds = true;
    self.contentImageView.center = self.center;
    [self addSubview:self.messageLabel];
    [self addSubview:self.contentImageView];
}

+ (void)showMessageHUDWithText:(NSString *)text type:(EZDImageType)type{
    CGFloat displayTime = .25;
    EZDMessageHUD *hud = [self shareHUD];
    if (text) {
        displayTime += text.length * 0.025;
        hud.messageLabel.text = text;
        hud.messageLabel.ezd_size = [text boundingRectWithSize:CGSizeMake(hud.ezd_width-36, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:hud.messageLabel.font} context:nil].size;
        hud.messageLabel.ezd_centerX = hud.ezd_centerX;
        hud.messageLabel.ezd_y = hud.contentImageView.ezd_maxY;
    }else{
        [hud.messageLabel removeFromSuperview];
    }
    
    hud.contentImageView.image = [EZDImage imageWithType:type];
    [[EZDSystemUtil currentWindow] addSubview:hud];
    hud.alpha = 0;
    [UIView animateWithDuration:.1 animations:^{
        hud.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(displayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.1 animations:^{
                hud.alpha = 0;
            } completion:^(BOOL finished) {
                [hud removeFromSuperview];
            }];
        });
    }];
}

@end
