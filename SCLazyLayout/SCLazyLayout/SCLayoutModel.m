//
//  SCLayoutModel.m
//  SCLazyLayout
//
//  Created by git on 2017/3/3.
//  Copyright © 2017年 git. All rights reserved.
//

#import "SCLayoutModel.h"

@interface SCLayoutModel ()

@end

@implementation SCLayoutModel

- (NSMutableString*)layoutString;
{
    return _layoutString ?: (_layoutString = [[NSMutableString alloc] init]);
}

- (void)setView:(UIView *)view
{
    _view = view;
    _layoutString = nil;
    [self.layoutString appendString:SCIntToString(view.tag)];
    [self dot];
}

- (SCLayoutModel*)left
{
    [self.layoutString appendString:@"left"];
    [self seg];
    return self;
}

- (SCLayoutModel*)right
{
    [self.layoutString appendString:@"right"];
    [self seg];
    return self;
}

- (SCLayoutModel*)centerX
{
    [self.layoutString appendString:@"centerX"];
    [self seg];
    return self;
}

- (SCLayoutModel*)top
{
    [self.layoutString appendString:@"top"];
    [self seg];
    return self;
}

- (SCLayoutModel*)bottom
{
    [self.layoutString appendString:@"bottom"];
    [self seg];
    return self;
}

- (SCLayoutModel*)centerY
{
    [self.layoutString appendString:@"centerY"];
    [self seg];
    return self;
}

- (SCLayoutModel*)width
{
    [self.layoutString appendString:@"width"];
    [self seg];
    return self;
}

- (SCLayoutModel*)height
{
    [self.layoutString appendString:@"height"];
    [self seg];
    return self;
}

- (LayoutBlock)equalTo
{
    return ^SCLayoutModel* (NSString* layoutString){
        [self.layoutString appendString:layoutString];
        [self seg];
        return self;
    };
}

- (OffsetBlock)offset
{
    return ^SCLayoutModel* (CGFloat value){
        [self.layoutString appendString:[NSString stringWithFormat:@"%.2f",value]];
        return self;
    };
}

- (void)dot
{
    [self.layoutString appendString:@"."];
}

- (void)seg
{
    [self.layoutString appendString:@"|"];
}

+ (void)tryInsertLayout:(SCLayoutModel*)layout IntoLayouts:(NSArray<SCLayoutModel*>*)layouts Complete:(void(^)(NSArray* returnLayouts, BOOL isSuccess))complete
{
    NSString *keyWord = [[[layout.layoutString componentsSeparatedByString:@"|"].firstObject componentsSeparatedByString:@"."] objectAtIndex:1];//TODO: check if crash
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:layouts];
    BOOL isHorizontal = [layout.layoutString rangeOfString:@"width"].length > 0 ||
                        [layout.layoutString rangeOfString:@"left"].length > 0 ||
                        [layout.layoutString rangeOfString:@"right"].length > 0 ||
                        [layout.layoutString rangeOfString:@"centerX"].length > 0;
    NSInteger constraintCount = 0;  //at same axis
    for (SCLayoutModel *otherLayout in array)
    {
        if (otherLayout.view == layout.view)    //locate the view
        {
            NSString *otherKeyWord = [[[otherLayout.layoutString componentsSeparatedByString:@"|"].firstObject componentsSeparatedByString:@"."] objectAtIndex:1];
            if ([keyWord isEqualToString:otherKeyWord])//same type of constraint
            {
                [array removeObject:otherLayout];
                break;
            }
            if (isHorizontal)
            {
                if([otherLayout.layoutString rangeOfString:@"width"].length > 0 ||
                   [otherLayout.layoutString rangeOfString:@"left"].length > 0 ||
                   [otherLayout.layoutString rangeOfString:@"right"].length > 0 ||
                   [otherLayout.layoutString rangeOfString:@"centerX"].length > 0)
                {
                    constraintCount++;
                }
            }
            else
            {
                if([otherLayout.layoutString rangeOfString:@"height"].length > 0 ||
                   [otherLayout.layoutString rangeOfString:@"top"].length > 0 ||
                   [otherLayout.layoutString rangeOfString:@"bottom"].length > 0||
                   [otherLayout.layoutString rangeOfString:@"centerY"].length > 0)
                {
                    constraintCount++;
                }
            }
        }
    }
    if (constraintCount>2)
    {
        NSLog(@"leak");
        complete(layouts, NO);
    }
    else if (constraintCount==2)
    {
        NSLog(@"full");
        complete(layouts, NO);
    }
    else
    {
        [array addObject:layout];
        complete(array, YES);
    }
}

@end
