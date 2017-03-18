//
//  SCLazyLayout.m
//  SCLazyLayout
//
//  Created by git on 2017/3/1.
//  Copyright © 2017年 git. All rights reserved.
//

#import "SCLazyLayout.h"

@implementation SCLazyLayout

+ (SCLazyLayout*)shareInstance;
{
    static SCLazyLayout *instance;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[SCLazyLayout alloc] init];
            instance.multiplyScaleX = 1.0f;
            instance.multiplyScaleY = 1.0f;
        });
    }
    return instance;
}

+ (void)setEnvironment:(SCLazyEviromentType)enviroment
{
    [SCLazyLayout shareInstance].isLive = (enviroment==SCLazyEviromentLive);
    [SCLazyLayout shareInstance].isWaste = (enviroment==SCLazyEviromentWaste);
    
    NSError *error;
    if (enviroment==SCLazyEviromentSandbox)
    {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dirPath = [documentPath stringByAppendingPathComponent:@"SCLazyLayoutFile/"];
        NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
        NSMutableDictionary *viewLayoutInfo = [NSMutableDictionary dictionary];
        for (NSString *viewControllerTitle in dirs)
        {
            NSString *dir = [dirPath stringByAppendingPathComponent:viewControllerTitle];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
            for (NSString *viewTitle in files)
            {
                if ([viewTitle isEqualToString:@".DS_Store"])
                {
                    continue;
                }
                NSString *filePath = [dir stringByAppendingPathComponent:viewTitle];
                NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
                NSArray *layouts = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                if (layouts==nil)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    continue;
                }
                [viewLayoutInfo setObject:layouts forKey:[viewTitle componentsSeparatedByString:@"."].firstObject];
            }
        }
        [SCLazyLayout shareInstance].layoutInfo = viewLayoutInfo;
        NSLog(@"\n\
————————————————————————————————————————————————————\n\
              Sandbox\n\
Direction:\n\
%@\n\n\
Move to Bundle when alive!\n\
————————————————————————————————————————————————————\n\n",
              dirPath);
    }
    else if (enviroment==SCLazyEviromentLive)
    {
        NSArray *dirs = [[NSBundle mainBundle] pathsForResourcesOfType:@"" inDirectory:@"SCLazyLayoutFile" forLocalization:nil];
        NSMutableDictionary *viewLayoutInfo = [NSMutableDictionary dictionary];
        for (NSString *dir in dirs)
        {
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
//            NSString *viewControllerTitle = [dir componentsSeparatedByString:@"/"].lastObject;
            for (NSString *viewTitle in files)
            {
                if ([viewTitle isEqualToString:@".DS_Store"])
                {
                    continue;
                }
                NSString *filePath = [dir stringByAppendingPathComponent:viewTitle];
                NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
                NSArray *layouts = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                if (layouts==nil)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    continue;
                }
                [viewLayoutInfo setObject:layouts forKey:[viewTitle componentsSeparatedByString:@"."].firstObject];
            }
        }
        [SCLazyLayout shareInstance].layoutInfo = viewLayoutInfo;
    }
}

+ (NSString*)getViewControllerTitle;
{
    UIViewController *current_vc = [SCLazyLayout topViewController];
    NSString *current_vc_name = NSStringFromClass([current_vc class]);
    return current_vc_name;
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [SCLazyLayout _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [SCLazyLayout _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
