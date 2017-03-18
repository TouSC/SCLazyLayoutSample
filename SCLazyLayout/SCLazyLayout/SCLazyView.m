//
//  SCLazyView.m
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import "SCLazyView.h"
#import <objc/runtime.h>
#import "Masonry.h"
#import "SCLazyLayout.h"
#import "SCLazyCanvas.h"
#import "SCLayoutModel.h"
#import "UIView+RectHelper.h"
#import "SCLayoutControl.h"

#define SCScreenWidth [UIScreen mainScreen].bounds.size.width
#define SCScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCValueRect(rect) [NSValue valueWithCGRect:rect]
#define SCValuePoint(point) [NSValue valueWithCGPoint:point]

@interface SCLazyView ()
<SCLazyCanvasDelegate,
UIGestureRecognizerDelegate>

@property(nonatomic,strong)NSMutableArray *labels;
@property(nonatomic,strong)NSMutableArray *imageViews;
@property(nonatomic,strong)NSMutableArray *frames;
@property(nonatomic,strong)NSMutableArray *sensitives;
@property(nonatomic,strong)NSMutableArray *controllers;

@end

@implementation SCLazyView
{
    UIView *superview;
    CGRect _originFrame;
    CGPoint originPositionInView;
    CGFloat originX;
    CGFloat originY;
    CGFloat originWidth;
    CGFloat originHeight;
    CGPoint originCenter;
    NSArray *activeXs;
    NSArray *activeYs;
    NSInteger selectedCount;
}

#pragma mark - Overide
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    if ([SCLazyLayout shareInstance].isLive)
    {
        return [super pointInside:point withEvent:event];
    }
    else
    {
        if (self.y+point.y > [SCLazyCanvas shareInstance].navigationView.height &&
            self.y+point.y < [SCLazyCanvas shareInstance].tabView.y - 30)//30 is vertical horizontal button
        {
            return YES;
        }
        return NO;
    }
}

#pragma mark - set get

- (NSMutableArray*)labels;
{
    return _labels ?: (_labels = [[NSMutableArray alloc] init]);
}

- (NSMutableArray*)imageViews;
{
    return _imageViews ?: (_imageViews = [[NSMutableArray alloc] init]);
}

- (NSMutableArray*)frames;
{
    return _frames ?: (_frames = [[NSMutableArray alloc] init]);
}

- (NSMutableArray*)sensitives;
{
    return _sensitives ?: (_sensitives = [[NSMutableArray alloc] init]);
}

- (NSMutableArray*)controllers;
{
    return _controllers ?: (_controllers = [[NSMutableArray alloc] init]);
}

- (NSArray*)layouts;
{
    return _layouts ?: (_layouts = [[NSArray alloc] init]);
}

#pragma mark - layout (init)
- (void)drawRect:(CGRect)rect;
{
    ;
}

- (void)lazyLayout;
{
    if ([SCLazyLayout shareInstance].isWaste)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self lazyLayoutSubviews];
        if ([SCLazyLayout shareInstance].isLive)
        {
            return;
        }
        superview = self.superview;
        _originFrame = self.frame;
        UILongPressGestureRecognizer *activePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressActiveView:)];
        [self addGestureRecognizer:activePress];
    });
}

- (void)lazyLayoutSubviews
{
    for (NSDictionary *layoutInfo in [SCLazyLayout shareInstance].layoutInfo[self.uuid])
    {
        UIView *subview = [self viewWithTag:[layoutInfo[@"tag"] integerValue]];
        if (subview==nil)
        {
            continue;
        }
        CGFloat x = [layoutInfo[@"x"] floatValue];
        CGFloat y = [layoutInfo[@"y"] floatValue];
        CGFloat width = [layoutInfo[@"width"] floatValue];
        CGFloat height = [layoutInfo[@"height"] floatValue];
        subview.frame = CGRectMake(x, y, width, height);
        
        NSArray *layouts = layoutInfo[@"layout"];
        for (NSString *layout in layouts)
        {
            NSArray *component = [layout componentsSeparatedByString:@"|"];
            if (component.count==3)
            {
                NSInteger targetTag = [[component[0] componentsSeparatedByString:@"."][0] integerValue];
                UIView *targetView = [self viewWithTag:targetTag];
                NSString *targetConstraint = [component[0] componentsSeparatedByString:@"."][1];
                NSInteger relateTag = [[component[1] componentsSeparatedByString:@"."][0] integerValue];
                UIView *relateView = relateTag==0 ? self : [self viewWithTag:relateTag];
                NSString *relateConstraint = [component[1] componentsSeparatedByString:@"."][1];
                CGFloat value = [component[2] floatValue];
                [targetView mas_updateConstraints:^(MASConstraintMaker *make) {
                    (
                        [targetConstraint isEqualToString:@"top"] ? make.top :
                        [targetConstraint isEqualToString:@"left"] ? make.left :
                        [targetConstraint isEqualToString:@"bottom"] ? make.bottom :
                        [targetConstraint isEqualToString:@"right"] ? make.right :
                        [targetConstraint isEqualToString:@"centerX"] ? make.centerX :
                        [targetConstraint isEqualToString:@"centerY"] ? make.centerY : make.edges
                    ).equalTo
                    (
                        [relateConstraint isEqualToString:@"mas_top"] ? relateView.mas_top :
                        [relateConstraint isEqualToString:@"mas_left"] ? relateView.mas_left :
                        [relateConstraint isEqualToString:@"mas_bottom"] ? relateView.mas_bottom :
                        [relateConstraint isEqualToString:@"mas_right"] ? relateView.mas_right :
                        [relateConstraint isEqualToString:@"mas_centerX"] ? relateView.mas_centerX :
                        [relateConstraint isEqualToString:@"mas_centerY"] ? relateView.mas_centerY : relateView
                    ).offset
                    (
                        value
                    );
                }];
            }
            else if (component.count==2)
            {
                NSInteger targetTag = [[component[0] componentsSeparatedByString:@"."][0] integerValue];
                UIView *targetView = [self viewWithTag:targetTag];
                NSString *targetConstraint = [component[0] componentsSeparatedByString:@"."][1];
                CGFloat value = [component[1] floatValue];
                [targetView mas_updateConstraints:^(MASConstraintMaker *make) {
                    (
                     [targetConstraint isEqualToString:@"width"] ? make.width :
                     [targetConstraint isEqualToString:@"height"] ? make.height : make.width
                     ).offset
                    (
                        value
                    );
                }];
            }
        }
    }
}

- (void)pressActiveView:(UILongPressGestureRecognizer*)ges
{
    [self removeAllConstraints:self];
    for (UIView *subview in self.subviews)
    {
        [self removeAllConstraints:subview];
    }
    if (ges.state!=UIGestureRecognizerStateBegan)
        return;
    CGFloat canvasWidth = SCScreenWidth;
    CGFloat canvasHeight = SCScreenHeight-[SCLazyCanvas shareInstance].navigationView.height-[SCLazyCanvas shareInstance].tabView.height;
    _scale = MIN(canvasWidth/self.width, canvasHeight/self.height);
    __weak typeof(SCLazyView) *weakSelf = self;
    [SCLazyCanvas shareInstance].delegate = self;
    [SCLazyCanvas shareInstance].viewControllerTitle = [SCLazyLayout getViewControllerTitle];
    [SCLazyCanvas shareInstance].viewTitle = self.uuid;
    [[SCLazyCanvas shareInstance] addView:self Progress:^{
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.frame = CGRectMake(0, 0, weakSelf.width * _scale, weakSelf.height * _scale);
            weakSelf.center = CGPointMake(SCScreenWidth/2, [SCLazyCanvas shareInstance].navigationView.height + canvasHeight/2);
            for (UIView *subview in weakSelf.subviews)
            {
                subview.frame = CGRectMake(subview.x * _scale, subview.y * _scale, subview.width * _scale, subview.height * _scale);
            }
        } completion:^(BOOL finished) {
            [self removeGestureRecognizer:ges];
            weakSelf.isActived = YES;
            [weakSelf activeSubviews:YES];
            [weakSelf setNeedsDisplay];
        }];
    } Complete:^(BOOL isSave){
        [self addGestureRecognizer:ges];
        [superview addSubview:weakSelf];
        weakSelf.isActived = NO;
        [weakSelf activeSubviews:NO];
        weakSelf.frame = _originFrame;
        if (isSave)
        {
            for (UIView *subview in self.subviews)
            {
                subview.frame = CGRectMake(subview.x / _scale, subview.y / _scale, subview.width / _scale, subview.height / _scale);
            }
        }
        else
        {
            int i=0;
            for (UIView *subview in self.subviews)
            {
                subview.frame = [self.frames[i] CGRectValue];
                i++;
            }
        }
        [self.frames removeAllObjects];
        [self setNeedsDisplay];
    }];
}

#pragma mark - layout (subviews)
static const NSString *interactionEnableKey = @"interactionEnable";
static const NSString *frameLayerKey = @"frameLayer";
static const NSString *panKey = @"pan";
- (void)activeSubviews:(BOOL)isActive
{
    if (isActive)
    {
        ;
    }
    else
    {
        [self removeControllers];
    }
    for (UIView *subview in self.subviews)
    {
        if (isActive)
        {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSubview:)];
            pan.delegate = self;
            [subview addGestureRecognizer:pan];
            objc_setAssociatedObject(subview, &interactionEnableKey, @(subview.isUserInteractionEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(subview, &panKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            subview.userInteractionEnabled = YES;
            [self.frames addObject:SCValueRect(CGRectMake(subview.x / _scale, subview.y / _scale, subview.width / _scale, subview.height / _scale))];
            [self addController:subview];
        }
        else
        {
            UIPanGestureRecognizer *pan = objc_getAssociatedObject(subview, &panKey);
            BOOL isUserInteractionEnable = [objc_getAssociatedObject(subview, &interactionEnableKey) boolValue];
            subview.userInteractionEnabled = isUserInteractionEnable;
            [subview removeGestureRecognizer:pan];
        }
    }
}

- (void)panSubview:(UIPanGestureRecognizer*)ges;
{
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        originCenter = ges.view.center;
        originPositionInView = [ges locationInView:self];
    }
    else if (ges.state == UIGestureRecognizerStateEnded)
    {
        
    }
    [self setNeedsDisplay];
    CGPoint positionInView = [ges locationInView:self];
    ges.view.center = CGPointMake(originCenter.x + positionInView.x - originPositionInView.x,
                                  originCenter.y + positionInView.y - originPositionInView.y);
}

#pragma mark - Controller
static const NSString *subviewKey = @"subview";
static const NSString *indexKey = @"index";

- (void)addController:(UIView*)subview
{
    /*
        0     1
        |-----|
        |  4  |
        |-----|
        3     2
    */
    NSArray *points = @[
                        @[subview.mas_left,subview.mas_top],
                        @[subview.mas_right,subview.mas_top],
                        @[subview.mas_right,subview.mas_bottom],
                        @[subview.mas_left,subview.mas_bottom],
                        
                        @[subview.mas_centerX,subview.mas_centerY],
                        ];
    for (int i=0; i<points.count; i++)
    {
        NSArray *point = points[i];
        SCLayoutControl *controller = [SCLayoutControl new];
        [self addSubview:controller];
        controller.mas_key = [NSString stringWithFormat:@"controller%d",i];
        [controller mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(point[0]);
            make.centerY.equalTo(point[1]);
            make.width.height.offset(20);
        }];
        [controller addTarget:self action:@selector(clickController:) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panController:)];
        pan.delaysTouchesBegan = NO;
        [controller addGestureRecognizer:pan];
        objc_setAssociatedObject(controller, &subviewKey, subview, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(controller, &indexKey, @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.controllers addObject:controller];
    }
}

- (void)layoutControllers
{
    for (UIView *controller in self.controllers)
    {
        NSInteger index = [objc_getAssociatedObject(controller, &indexKey) integerValue];
        UIView *subview = objc_getAssociatedObject(controller, &subviewKey);
        NSArray *points = @[
                            @[subview.mas_left,subview.mas_top],
                            @[subview.mas_right,subview.mas_top],
                            @[subview.mas_right,subview.mas_bottom],
                            @[subview.mas_left,subview.mas_bottom],
                            
                            @[subview.mas_centerX,subview.mas_centerY],
                            ];
        NSArray *point = points[index];
        [controller mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(point[0]);
            make.centerY.equalTo(point[1]);
            make.width.height.offset(20);
        }];
    }
}

- (void)removeControllers
{
    for (UIView *controller in self.controllers)
    {
        [controller removeFromSuperview];
    }
    [self.controllers removeAllObjects];
}

- (void)clickController:(UIButton*)sender
{
    selectedCount = 0;
    if (!sender.isSelected)
    {
        UIButton *selectedController = nil;
        for (UIButton *otherSender in self.controllers)
        {
            if (otherSender.isSelected)
            {
                selectedController = otherSender;
                break;
            }
        }
        if (selectedController != nil)
        {
            //Match
            NSInteger targetIndex = [objc_getAssociatedObject(selectedController, &indexKey) integerValue];
            NSInteger relateTargetIndex = [objc_getAssociatedObject(sender, &indexKey) integerValue];
            [self generateConstraint:selectedController Index:targetIndex RelateController:sender RelateIndex:relateTargetIndex];
            selectedCount = 1;
        }
    }
    sender.selected = !sender.isSelected;
    if (sender.isSelected)
    {
        selectedCount ++;
    }
    if (selectedCount!=2)
    {
        [[SCLazyCanvas shareInstance] reset];
    }
}

- (void)SCLazyCanvas:(SCLazyCanvas *)canvas didSelectButton:(UIButton *)button Position:(SCConstraintPosition)position
{
    if (selectedCount==1)
    {
        UIButton *selectedController = nil;
        for (UIButton *otherSender in self.controllers)
        {
            if (otherSender.isSelected)
            {
                selectedController = otherSender;
                break;
            }
        }
        button.selected = YES;
        NSInteger targetIndex = [objc_getAssociatedObject(selectedController, &indexKey) integerValue];
        NSInteger reflexIndex = position == SCConstraintTop ? 0 :
                                position == SCConstraintLeft ? 0 :
                                position == SCConstraintBottom ? 2 :
                                position == SCConstraintRight ? 2 :
                                position == SCConstraintCenter ? 4 : 0;
        [self generateConstraint:selectedController Index:targetIndex RelateController:nil RelateIndex:reflexIndex];
    }
}

#pragma mark Generate Constrant

- (void)generateConstraint:(UIButton*)mainCtl Index:(NSInteger)index RelateController:(UIButton*)relateCtl RelateIndex:(NSInteger)relateIndex;
{
    UIView *mainView = objc_getAssociatedObject(mainCtl, &subviewKey);
    UIView *relateView = relateCtl==nil ? self : objc_getAssociatedObject(relateCtl, &subviewKey);
    __block SCConstraintType constraintType = SCConstraintUnknow;
    __block SCLayoutTarget layoutTarget = SCLayoutUnknow;
    __block SCLayoutTarget layoutRelateTarget = SCLayoutUnknow;
    if (mainView==relateView)
    {
        if (mainCtl.center.x==relateCtl.center.x)
        {
            constraintType = SCConstraintHeight;
        }
        else if (mainCtl.center.y==relateCtl.center.y)
        {
            constraintType = SCConstraintWidth;
        }
    }
    __weak typeof(SCLazyView*)weakSelf = self;
    [[SCLazyCanvas shareInstance] waitForInput:(mainView==relateView) Complete:^(CGFloat value, SCConstraintType type) {
        if (type==SCConstraintUnknow)
        {
            type = constraintType;
        }
        mainCtl.selected = NO;
        relateCtl.selected = NO;
        CGRect originalRect = mainView.frame;
        SCLayoutModel *m = [[SCLayoutModel alloc] init];
        m.view = mainView;
        __block NSInteger originTag = relateView.tag;
        [UIView animateWithDuration:0.5 animations:^{
            if (relateView==self)
            {
                relateView.tag = 0;
            }
            switch (type)
            {
                case SCConstraintWidth:
                {
                    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(weakSelf.mas_left).offset(originalRect.origin.x);
                        make.top.equalTo(weakSelf.mas_top).offset(originalRect.origin.y);
                        make.width.offset(value);
                        make.height.offset(originalRect.size.height);
                    }];
                    m.width.offset(value);
                    break;
                }
                case SCConstraintHeight:
                {
                    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(weakSelf.mas_left).offset(originalRect.origin.x);
                        make.top.equalTo(weakSelf.mas_top).offset(originalRect.origin.y);
                        make.width.offset(originalRect.size.width);
                        make.height.offset(value);
                    }];
                    m.height.offset(value);
                    break;
                }
                case SCConstraintHorizontal:
                {
                    if (index==0 || index==3)
                    {
                        layoutTarget = SCLayoutLeft;
                    }
                    else if (index==1 || index==2)
                    {
                        layoutTarget = SCLayoutRight;
                    }
                    else
                    {
                        layoutTarget = SCLayoutCenterX;
                    }
                    if (relateIndex==0 || relateIndex==3)
                    {
                        layoutRelateTarget = SCLayoutLeft;
                    }
                    else if (relateIndex==1 || relateIndex==2)
                    {
                        layoutRelateTarget = SCLayoutRight;
                    }
                    else
                    {
                        layoutTarget = SCLayoutCenterX;
                    }
                    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
                        (layoutTarget==SCLayoutLeft ? make.left : layoutTarget==SCLayoutRight ? make.right : make.centerX).equalTo(layoutRelateTarget==SCLayoutLeft ? relateView.mas_left : layoutRelateTarget==SCLayoutRight ? relateView.mas_right : relateView.mas_centerX).offset(value);
                        if (layoutTarget==SCLayoutLeft)
                        {
                            make.right.offset(-(weakSelf.width-originalRect.origin.x-originalRect.size.width));
                        }
                        else if (layoutTarget==SCLayoutRight)
                        {
                            make.left.offset(originalRect.origin.x);
                        }
                        else
                        {
                            make.width.offset(originalRect.size.width);
                        }
                        make.top.equalTo(self.mas_top).offset(originalRect.origin.y);
                        make.height.offset(originalRect.size.height);
                    }];
                    (layoutTarget==SCLayoutLeft ? m.left : layoutTarget==SCLayoutRight ? m.right : m.centerX).equalTo(layoutRelateTarget==SCLayoutLeft ? relateView.my_left : layoutRelateTarget==SCLayoutRight ? relateView.my_right : relateView.my_centerX).offset(value);
                    break;
                }
                case SCConstraintVertical:
                {
                    if (index==0 || index==1)
                    {
                        layoutTarget = SCLayoutTop;
                    }
                    else if (index==2 || index==3)
                    {
                        layoutTarget = SCLayoutBottom;
                    }
                    else
                    {
                        layoutTarget = SCLayoutCenterY;
                    }
                    if (relateIndex==0 || relateIndex==1)
                    {
                        layoutRelateTarget = SCLayoutTop;
                    }
                    else if (relateIndex==2 || relateIndex==3)
                    {
                        layoutRelateTarget = SCLayoutBottom;
                    }
                    else
                    {
                        layoutRelateTarget = SCLayoutCenterY;
                    }
                    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
                        (layoutTarget==SCLayoutTop ? make.top : layoutTarget==SCLayoutBottom ? make.bottom : make.centerY).equalTo(layoutRelateTarget==SCLayoutTop ? relateView.mas_top : layoutRelateTarget==SCLayoutBottom ? relateView.mas_bottom : relateView.mas_centerY).offset(value);
                        if (layoutTarget==SCLayoutTop)
                        {
                            make.bottom.offset(-(weakSelf.height-originalRect.origin.y-originalRect.size.height));
                        }
                        else if (layoutTarget==SCLayoutBottom)
                        {
                            make.top.offset(originalRect.origin.y);
                        }
                        else
                        {
                            make.height.offset(originalRect.size.height);
                        }
                        make.left.equalTo(weakSelf.mas_left).offset(originalRect.origin.x);
                        make.width.offset(originalRect.size.width);
                    }];
                    (layoutTarget==SCLayoutTop ? m.top : layoutTarget==SCLayoutBottom ? m.bottom : m.centerY).equalTo(layoutRelateTarget==SCLayoutTop ? relateView.my_top : layoutRelateTarget==SCLayoutBottom ?  relateView.my_bottom : relateView.my_centerY).offset(value);
                    break;
                }
                default:
                    break;
            }
            [mainView.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            relateView.tag = originTag;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf removeAllConstraints:mainView];
                [weakSelf layoutControllers];
                [SCLayoutModel tryInsertLayout:m IntoLayouts:weakSelf.layouts Complete:^(NSArray *returnLayouts, BOOL isSuccess) {
                    weakSelf.layouts = returnLayouts;
                    [weakSelf setNeedsDisplay];
                }];
            });
        }];
    }];
}

- (void)panController:(UIPanGestureRecognizer*)ges
{
    if ([ges.view.mas_key isEqualToString:@"controller4"])//center
    {
        return;
    }
    UIView *subview = objc_getAssociatedObject(ges.view, &subviewKey);
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        originCenter = ges.view.center;
        originPositionInView = [ges locationInView:self];
        originX = subview.x;
        originY = subview.y;
        originWidth = subview.width;
        originHeight = subview.height;
    }
    CGPoint positionInView = [ges locationInView:self];
    CGFloat xOffset = positionInView.x - originPositionInView.x;
    CGFloat yOffset = positionInView.y - originPositionInView.y;
    ges.view.center = CGPointMake(originCenter.x + xOffset,
                                  originCenter.y + yOffset);
    NSInteger index = [objc_getAssociatedObject(ges.view, &indexKey) integerValue];
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    switch (index)
    {
        case 0:
        {
            x = originX + xOffset;
            y = originY + yOffset;
            width = originWidth - xOffset;
            height = originHeight - yOffset;
            break;
        }
        case 1:
        {
            x = originX;
            y = originY + yOffset;
            width = originWidth + xOffset;
            height = originHeight - yOffset;
            break;
        }
        case 2:
        {
            x = originX;
            y = originY;
            width = originWidth + xOffset;
            height = originHeight + yOffset;
            break;
        }
        case 3:
        {
            x = originX + xOffset;
            y = originY;
            width = originWidth - xOffset;
            height = originHeight + yOffset;
            break;
        }
        default:
            break;
    }
    
    subview.frame = CGRectMake(x,
                               y,
                               width,
                               height);
    [self setNeedsLayout];
}

#pragma mark - Func

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)removeAllConstraints:(UIView*)view
{
    UIView *_superview = view.superview;
    while (_superview != nil) {
        for (NSLayoutConstraint *c in _superview.constraints) {
            if (c.firstItem == view || c.secondItem == view) {
                [_superview removeConstraint:c];
            }
        }
        _superview = _superview.superview;
    }
    
    [view removeConstraints:view.constraints];
    view.translatesAutoresizingMaskIntoConstraints = YES;
}

@end
