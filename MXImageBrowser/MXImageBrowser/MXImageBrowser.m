//
//  MXImageBrowser.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXImageBrowser.h"
#import "MXTransitionManager.h"
#import "MXImageContentView.h"
#import <Masonry.h>
#import "MXBrowserDefine.h"

@interface MXImageBrowser () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) MXTransitionManager *transitionManager;
@property (nonatomic, weak) MXImageContentView *container;
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation MXImageBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.transitionManager = [MXTransitionManager new];
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupTransition];
    [self respondBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.presentingViewController.view.window.windowLevel = UIWindowLevelStatusBar;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.presentingViewController.view.window.windowLevel = UIWindowLevelNormal;
}

- (void)setupUI {
    MXImageContentView *contentView = [[MXImageContentView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets = UIEdgeInsetsZero;
    }];
    self.container = contentView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    [self.view addSubview:pageControl];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
        }
        else {
            make.bottom.equalTo(self.view).offset(-20);
        }
        make.width.equalTo(@(200));
        make.height.equalTo(@(20));
    }];
    pageControl.numberOfPages = self.imageUrls.count;
    pageControl.currentPage = self.index;
    self.container.pageControl = pageControl;
    [self.container mx_reloadData:self.imageUrls];
}

- (void)setupTransition {
    mx_Weakify(self)
    self.transitionManager.willPresent = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
        mx_Weakself.indexView.hidden = YES;
    };
    
    self.transitionManager.willDismiss = ^(UIView * _Nonnull fromView, UIView * _Nonnull toView) {
        mx_Weakself.indexView.hidden = NO;
    };
}

- (void)respondBlock {
    mx_Weakify(self)
    self.container.mxContentDismissBlock = ^{
        [mx_Weakself dismiss];
    };
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UIViewControllerTransitioningDelegate>
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}



@end
