//
//  SCLazyLayout.h
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SCLazyEviromentSandbox,
    SCLazyEviromentLive,
    SCLazyEviromentWaste,
}SCLazyEviromentType;

@interface SCLazyLayout : NSObject

+ (SCLazyLayout*)shareInstance;
+ (void)setEnvironment:(SCLazyEviromentType)enviroment;

+ (NSString*)getViewControllerTitle;

@property(nonatomic,assign)BOOL isLive;
@property(nonatomic,assign)BOOL isWaste;
@property(nonatomic,assign)BOOL isRecorgnizeDevice;
@property(nonatomic,assign)CGFloat multiplyScaleX;
@property(nonatomic,assign)CGFloat multiplyScaleY;
@property(nonatomic,strong)NSDictionary *layoutInfo;

@end
