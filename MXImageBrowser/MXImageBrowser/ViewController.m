//
//  ViewController.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "ViewController.h"
#import "MXImageBrowser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 200, 30);
    [self.view addSubview:btn];
    btn.tag = 101;
    [btn setBackgroundColor:[UIColor darkGrayColor]];
    [btn addTarget:self action:@selector(didClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClick {
    MXImageBrowser *browser = [MXImageBrowser new];
    browser.index = 0;
    browser.imageUrls = @[@"", @"", @"", @""];
    browser.indexView = [self.view viewWithTag:101];
    [self presentViewController:browser animated:YES completion:nil];
}


@end
