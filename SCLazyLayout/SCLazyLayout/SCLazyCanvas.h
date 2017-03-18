//
//  SCLazyCanvas.h
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLazyView.h"
@class SCLazyCanvas;
typedef enum {
    SCConstraintWidth = 1<<0,
    SCConstraintHeight = 1<<1,
    SCConstraintVertical = 1<<2,
    SCConstraintHorizontal = 1<<3,
    SCConstraintUnknow = 1<<4,
}SCConstraintType;

typedef enum {
    SCConstraintTop = 101,
    SCConstraintLeft,
    SCConstraintBottom,
    SCConstraintRight,
    SCConstraintCenter,
}SCConstraintPosition;

@protocol SCLazyCanvasDelegate <NSObject>

- (void)SCLazyCanvas:(SCLazyCanvas*)canvas didSelectButton:(UIButton*)button Position:(SCConstraintPosition)position;

@end

@interface SCLazyCanvas : UIView

@property(nonatomic,strong)NSString *viewControllerTitle;
@property(nonatomic,strong)NSString *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property(nonatomic,weak)SCLazyView *lazyView;
@property(nonatomic,weak)id<SCLazyCanvasDelegate>delegate;

+ (SCLazyCanvas*)shareInstance;
- (void)reset;
- (void)addView:(SCLazyView*)lazyView Progress:(void(^)(void))progress Complete:(void(^)(BOOL isSave))complete;
- (void)waitForInput:(BOOL)isInner Complete:(void(^)(CGFloat value, SCConstraintType type))complete;

@end
