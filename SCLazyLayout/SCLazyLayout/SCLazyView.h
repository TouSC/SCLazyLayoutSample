//
//  SCLazyView.h
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCLayoutModel;

typedef enum {
    SCLayoutLeft,
    SCLayoutRight,
    SCLayoutTop,
    SCLayoutBottom,
    SCLayoutCenterX,
    SCLayoutCenterY,
    SCLayoutUnknow,
}SCLayoutTarget;

@interface SCLazyView : UIView

@property(nonatomic,assign)BOOL isActived;
@property(nonatomic,assign)CGFloat scale;
@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,strong)NSArray<SCLayoutModel*> *layouts;

- (void)lazyLayout;

@end
