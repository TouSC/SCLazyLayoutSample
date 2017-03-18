//
//  ViewController.m
//  SCLazyLayoutSample
//
//  Created by 唐绍成 on 2017/3/3.
//  Copyright © 2017年 唐绍成. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TestView *view = [[TestView alloc] init];
    view.uuid = @"TestView";
    [view lazyLayout];
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
