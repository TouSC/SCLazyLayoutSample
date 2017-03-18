//
//  UIView+RectHelper.m
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import "UIView+RectHelper.h"

@implementation UIView (RectHelper)

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setMy_left:(NSString *)my_left
{
    ;
}

- (NSString*)my_left;
{
    return [NSString stringWithFormat:@"%d.mas_left",(int)self.tag];
}

- (void)setMy_right:(NSString *)my_right
{
    ;
}

- (NSString*)my_right
{
    return [NSString stringWithFormat:@"%d.mas_right",(int)self.tag];
}

- (void)setMy_centerX:(NSString *)my_centerX
{
    ;
}

- (NSString*)my_centerX
{
    return [NSString stringWithFormat:@"%d.mas_centerX",(int)self.tag];
}

- (void)setMy_top:(NSString *)my_top
{
    ;
}

- (NSString*)my_top
{
    return [NSString stringWithFormat:@"%d.mas_top",(int)self.tag];
}

- (void)setMy_bottom:(NSString *)my_bottom
{
    ;
}

- (NSString*)my_bottom
{
    return [NSString stringWithFormat:@"%d.mas_bottom",(int)self.tag];
}

- (void)setMy_centerY:(NSString *)my_centerY
{
    ;
}

- (NSString*)my_centerY
{
    return [NSString stringWithFormat:@"%d.mas_centerY",(int)self.tag];
}

@end
