//
//  MXTransitionManager.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXTransitionManager.h"

@interface MXTransitionManager () {
    BOOL _isEnter;
}

@property (nonatomic, strong) UIImageView *animateImageView;
@property (nonatomic, assign) BOOL isTransitioning;
@property (nonatomic, strong, nonnull) UIView *coverView;

@end

@implementation MXTransitionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.animateImageView = [[UIImageView alloc] init];
        self.animateImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    if (!containerView) {
        return;
    }
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromController) {
        return;
    }
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toController) {
        return;
    }
    UIView *fromView = fromController.view;
    UIView *toView = toController.view;
    
    if (toController.isBeingPresented) {
        [self presentWithTransition:transitionContext
                          container:containerView
                               from:fromView
                                 to:toView
                         completion:^(BOOL flag) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                                 }];
    }
    
    if (fromController.isBeingDismissed) {
        [self dismissWithTransition:transitionContext
                          container:containerView
                               from:fromView
                                 to:toView
                         completion:^(BOOL flag) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

- (void)presentWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext
                    container:(UIView *)container
                         from:(UIView *)fromView
                           to:(UIView *)toView
                   completion:(void (^)(BOOL flag))completion {
    self.coverView.frame = container.frame;
    self.coverView.alpha = 0;
    [container addSubview:self.coverView];
    toView.frame = container.bounds;
    [container addSubview:toView];
    
    self.willPresent ? self.willPresent(fromView, toView) : nil;
    __weak typeof(self) weak_self = self;
    [self animateWithTransition:transitionContext
                     animations:^{
                         __strong typeof(weak_self) strong_self = weak_self;
                         strong_self.coverView.alpha = 1;
                         strong_self.inPresentation ? strong_self.inPresentation(fromView, toView) : nil;
                     }
                     completion:^(BOOL flag) {
                         __strong typeof(weak_self) strong_self = weak_self;
                         strong_self.didPresent ? strong_self.didPresent(fromView, toView) : nil;
                         completion(flag);
                     }];
}

- (void)dismissWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext
                    container:(UIView *)container
                         from:(UIView *)fromView
                           to:(UIView *)toView
                   completion:(void (^)(BOOL flag))completion {
    [container addSubview:fromView];
    self.willDismiss ? self.willDismiss(fromView, toView) : nil;
    __weak typeof(self) weak_self = self;
    [self animateWithTransition:transitionContext
                     animations:^{
                         __strong typeof(weak_self) strong_self = weak_self;
                         strong_self.coverView.alpha = 0;
                         strong_self.inDismissal ? strong_self.inDismissal(fromView, toView) : nil;
                     }
                     completion:^(BOOL flag) {
                         __strong typeof(weak_self) strong_self = weak_self;
                         strong_self.didDismiss ? strong_self.didDismiss(fromView, toView) : nil;
                         completion(flag);
                     }];
    
}

- (UIViewAnimationOptions)animationOptions {
    return 7 << 16;
}

- (void)animateWithTransition:(nullable id <UIViewControllerContextTransitioning>)transitionContext
                    animations:(void (^)(void))animations
                    completion:(void (^)(BOOL flag))completion {
    // Prevent other interactions disturb.
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:[self animationOptions]
                     animations:animations
                     completion:^(BOOL finished) {
                         completion(finished);
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverView.clipsToBounds = YES;
        _coverView.multipleTouchEnabled = NO;
        _coverView.userInteractionEnabled = NO;
    }
    return _coverView;
}

@end
