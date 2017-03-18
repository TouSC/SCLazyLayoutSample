//
//  TestView.m
//  SCLazyLayoutSample
//
//  Created by 唐绍成 on 2017/3/3.
//  Copyright © 2017年 唐绍成. All rights reserved.
//

#import "TestView.h"

@implementation TestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init;
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil].firstObject;
    if (self)
    {
        ;
    }
    return self;
}

@end
