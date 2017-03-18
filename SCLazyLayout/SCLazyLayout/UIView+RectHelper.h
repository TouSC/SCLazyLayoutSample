//
//  UIView+RectHelper.h
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RectHelper)

@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,strong)NSString *my_left;
@property(nonatomic,strong)NSString *my_right;
@property(nonatomic,strong)NSString *my_centerX;
@property(nonatomic,strong)NSString *my_top;
@property(nonatomic,strong)NSString *my_bottom;
@property(nonatomic,strong)NSString *my_centerY;

@end
