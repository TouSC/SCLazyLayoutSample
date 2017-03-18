//
//  SCLayoutControl.m
//  SCLazyLayoutSample
//
//  Created by git on 2017/3/17.
//  Copyright © 2017年 git. All rights reserved.
//

#import "SCLayoutControl.h"

@implementation SCLayoutControl
{
    CGRect originBounds;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.layer.cornerRadius = 5;
        self.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    [super drawRect:rect];
    originBounds = self.bounds;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
    {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    else
    {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.bounds = CGRectMake(originBounds.origin.x, originBounds.origin.y, originBounds.size.width * 0.8, originBounds.size.height * 0.8);
        }];
    }
    else
    {
        self.bounds = originBounds;
    }
}

@end
