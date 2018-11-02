//
//  ViewController.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "ViewController.h"
#import "MXImageBrowser.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>

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
    
    
    UIView *pview = [[UIView alloc] initWithFrame:CGRectZero];
    pview.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:pview];
    
    [pview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(300);
    }];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 101;
    [btn setBackgroundColor:[UIColor darkGrayColor]];
    [btn addTarget:self action:@selector(didClear) forControlEvents:UIControlEventTouchUpInside];
    [pview addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    }];
    
    UIImage *image = [UIImage imageNamed:@"1234567"];
    NSLog(@"size%@ %@", NSStringFromCGSize(image.size), @(image.scale).stringValue);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didClick {
    MXImageBrowser *browser = [MXImageBrowser new];
    browser.index = 0;
    browser.imageUrls = @[@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage001.jpg",
                          @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage002.jpg",
                          @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage003.jpg",
                          @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage004.jpg"];
    browser.indexView = [self.view viewWithTag:101];
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)didClear {
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:nil];
}


@end
