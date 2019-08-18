//
//  UIView+EZDAddition_frame.m
//  HoldCoin
//
//  Created by Song on 2018/10/8.
//  Copyright © 2018年 Beijing Bai Cheng Media Technology Co.LTD. All rights reserved.
//

#import "UIView+EZDAddition_frame.h"

@implementation UIView (EZDAddition_frame)

- (void)setEzd_x:(CGFloat)ezd_x{
    CGRect frame = self.frame;
    frame.origin.x = ezd_x;
    self.frame = frame;
}

- (void)setEzd_y:(CGFloat)ezd_y{
    CGRect frame = self.frame;
    frame.origin.y = ezd_y;
    self.frame = frame;
}

- (CGFloat)ezd_x{
    return self.frame.origin.x;
}

- (CGFloat)ezd_y{
    return self.frame.origin.y;
}

- (void)setEzd_centerX:(CGFloat)ezd_centerX{
    CGPoint center = self.center;
    center.x = ezd_centerX;
    self.center = center;
}

- (CGFloat)ezd_centerX{
    return self.center.x;
}

- (void)setEzd_centerY:(CGFloat)ezd_centerY{
    CGPoint center = self.center;
    center.y = ezd_centerY;
    self.center = center;
}

- (CGFloat)ezd_centerY{
    return self.center.y;
}

- (void)setEzd_maxX:(CGFloat)ezd_maxX{
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = ezd_maxX - self.ezd_width;
    self.frame = tempFrame;
}

- (CGFloat)ezd_maxX{
    return self.x+self.width;
}

- (void)setEzd_maxY:(CGFloat)ezd_maxY{
    CGRect tempFrame = self.frame;
    tempFrame.origin.y = ezd_maxY - self.ezd_height;
    self.frame = tempFrame;
}
- (CGFloat)ezd_maxY{
    return self.y+self.height;
}

- (void)setEzd_width:(CGFloat)ezd_width{
    CGRect frame = self.frame;
    frame.size.width = ezd_width;
    self.frame = frame;
}

- (void)setEzd_height:(CGFloat)ezd_height{
    CGRect frame = self.frame;
    frame.size.height = ezd_height;
    self.frame = frame;
}

- (CGFloat)ezd_height{
    return self.frame.size.height;
}

- (CGFloat)ezd_width{
    return self.frame.size.width;
}

- (void)setEzd_size:(CGSize)ezd_size{
    CGRect frame = self.frame;
    frame.size = ezd_size;
    self.frame = frame;
}

- (CGSize)ezd_size{
    return self.frame.size;
}

- (void)setEzd_origin:(CGPoint)ezd_origin{
    CGRect frame = self.frame;
    frame.origin = ezd_origin;
    self.frame = frame;
}

- (CGPoint)ezd_origin{
    return self.frame.origin;
}

@end
