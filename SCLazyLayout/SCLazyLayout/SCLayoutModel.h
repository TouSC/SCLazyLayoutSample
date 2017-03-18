//
//  SCLayoutModel.h
//  SCLazyLayout
//
//  Created by git on 2017/3/3.
//  Copyright © 2017年 git. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCIntToString(value) [NSString stringWithFormat:@"%d",(int)value]

@interface SCLayoutModel : NSObject

typedef SCLayoutModel*(^LayoutBlock)(NSString *layout);
typedef SCLayoutModel*(^OffsetBlock)(CGFloat value);

@property(nonatomic,strong)UIView *view;
@property(nonatomic,strong)SCLayoutModel *left;
@property(nonatomic,strong)SCLayoutModel *right;
@property(nonatomic,strong)SCLayoutModel *centerX;
@property(nonatomic,strong)SCLayoutModel *top;
@property(nonatomic,strong)SCLayoutModel *bottom;
@property(nonatomic,strong)SCLayoutModel *centerY;
@property(nonatomic,strong)SCLayoutModel *width;
@property(nonatomic,strong)SCLayoutModel *height;

@property(nonatomic,strong)NSMutableString *layoutString;

- (LayoutBlock)equalTo;
- (OffsetBlock)offset;

+ (void)tryInsertLayout:(SCLayoutModel*)layout IntoLayouts:(NSArray<SCLayoutModel*>*)layouts Complete:(void(^)(NSArray* returnLayouts, BOOL isSuccess))complete;

@end
