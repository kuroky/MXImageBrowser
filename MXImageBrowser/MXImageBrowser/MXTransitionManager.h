//
//  MXTransitionManager.h
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MXContextBlock)(UIView *fromView, UIView *toView);

@interface MXTransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy, nullable) MXContextBlock willPresent;
@property (nonatomic, copy, nullable) MXContextBlock inPresentation;
@property (nonatomic, copy, nullable) MXContextBlock didPresent;
@property (nonatomic, copy, nullable) MXContextBlock willDismiss;
@property (nonatomic, copy, nullable) MXContextBlock inDismissal;
@property (nonatomic, copy, nullable) MXContextBlock didDismiss;

@end

NS_ASSUME_NONNULL_END
