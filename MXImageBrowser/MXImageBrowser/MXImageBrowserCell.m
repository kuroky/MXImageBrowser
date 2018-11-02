//
//  MXImageBrowserCell.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXImageBrowserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MXImageBrowserCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    CGSize _containerSize;
    BOOL _isZooming;
    BOOL _isDragging;
    BOOL _bodyIsInCenter;
    
    BOOL _isGestureInteraction;
    CGPoint _gestureInteractionStartPoint;
    
    UIInterfaceOrientation _statusBarOrientationBefore;
}

@property (nonatomic, strong) UIScrollView *mainContentView;
@property (nonatomic, strong) UIImageView *mainImageView;

@end

@implementation MXImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        
        [self.contentView addSubview:self.mainContentView];
        [self.mainContentView addSubview:self.mainImageView];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"2014120107280906" ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        self.mainImageView.image = image;
        [self addGesture];
    }
    return self;
}

- (void)prepareForReuse {
    [self initVars];
    
    self.mainContentView.zoomScale = 1;
    [super prepareForReuse];
}

- (void)initVars {
    _isZooming = NO;
    _isDragging = NO;
    _bodyIsInCenter = YES;
    _containerSize = self.frame.size;
    _gestureInteractionStartPoint = CGPointZero;
    _statusBarOrientationBefore = UIInterfaceOrientationPortrait;
}

- (UIScrollView *)mainContentView {
    if (!_mainContentView) {
        _mainContentView = [UIScrollView new];
        _mainContentView.delegate = self;
        _mainContentView.showsHorizontalScrollIndicator = NO;
        _mainContentView.showsVerticalScrollIndicator = NO;
        _mainContentView.decelerationRate = UIScrollViewDecelerationRateFast;
        _mainContentView.maximumZoomScale = 1;
        _mainContentView.minimumZoomScale = 1;
        _mainContentView.alwaysBounceHorizontal = NO;
        _mainContentView.alwaysBounceVertical = NO;
        _mainContentView.layer.masksToBounds = NO;
        _mainContentView.frame = self.contentView.frame;
        if (@available(iOS 11.0, *)) {
            _mainContentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainContentView;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [UIImageView new];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.masksToBounds = YES;
        _mainImageView.frame = self.contentView.frame;
    }
    _mainImageView.backgroundColor = [UIColor blackColor];
    return _mainImageView;
}

- (void)addGesture {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapDouble:)];
    tapDouble.numberOfTapsRequired = 2;
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPan:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    [self.mainContentView addGestureRecognizer:tapSingle];
    [self.mainContentView addGestureRecognizer:tapDouble];
    [self.mainContentView addGestureRecognizer:pan];
}

- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    self.mxBrowserCellDismissBlock();
}

- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    //[self hideTailoringImageView];
    
    UIScrollView *scrollView = self.mainContentView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale)
        [scrollView setZoomScale:1 animated:YES];
    else
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
}

- (BOOL)currentIsLargeImageBrowsing {
    CGFloat sHeight = self.mainContentView.bounds.size.height,
    sWidth = self.mainContentView.bounds.size.width,
    sContentHeight = self.mainContentView.contentSize.height,
    sContentWidth = self.mainContentView.contentSize.width;
    return sContentHeight > sHeight || sContentWidth > sWidth;
}

- (void)respondsToPan:(UIPanGestureRecognizer *)pan {
    if ((CGRectIsEmpty(self.mainImageView.frame) || !self.mainImageView.image)) return;
    
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        self->_gestureInteractionStartPoint = point;
        
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateRecognized || pan.state == UIGestureRecognizerStateFailed) {
        
        // END
        if (_isGestureInteraction) {
            CGPoint velocity = [pan velocityInView:self.mainContentView];
            
            BOOL velocityArrive = ABS(velocity.y) > 800;//self->_giProfile.dismissVelocityY
            BOOL distanceArrive = ABS(point.y - self->_gestureInteractionStartPoint.y) > self->_containerSize.height * 0.22;//self->_giProfile.dismissScale
            
            BOOL shouldDismiss = distanceArrive || velocityArrive;
            if (shouldDismiss) {
                //self.yb_browserDismissBlock();
                [self restoreGestureInteractionWithDuration:0.15];
            } else {
                [self restoreGestureInteractionWithDuration:0.15];//self->_giProfile.restoreDuration
            }
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [pan velocityInView:self.mainContentView];
        CGFloat triggerDistance = 3;//self->_giProfile.triggerDistance;
        
        BOOL startPointValid = !CGPointEqualToPoint(self->_gestureInteractionStartPoint, CGPointZero);
        BOOL distanceArrive = ABS(point.x - self->_gestureInteractionStartPoint.x) < triggerDistance && ABS(velocity.x) < 500;
        BOOL upArrive = point.y - self->_gestureInteractionStartPoint.y > triggerDistance && self.mainContentView.contentOffset.y <= 1,
        downArrive = point.y - self->_gestureInteractionStartPoint.y < -triggerDistance && self.mainContentView.contentOffset.y + self.mainContentView.bounds.size.height >= MAX(self.mainContentView.contentSize.height, self.mainContentView.bounds.size.height) - 1;
        
        BOOL shouldStart = startPointValid && !_isGestureInteraction && (upArrive || downArrive) && distanceArrive && self->_bodyIsInCenter && !self->_isZooming;
        // START
        if (shouldStart) {
            if ([UIApplication sharedApplication].statusBarOrientation != self->_statusBarOrientationBefore) {
                //self.yb_browserDismissBlock();
            } else {
                //[self hideTailoringImageView];
                
                _gestureInteractionStartPoint = point;
                
                CGRect startFrame = self.mainContentView.frame;
                CGFloat anchorX = point.x / startFrame.size.width,
                anchorY = point.y / startFrame.size.height;
                self.mainContentView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
                self.mainContentView.userInteractionEnabled = NO;
                self.mainContentView.scrollEnabled = NO;
                
                //self.yb_browserScrollEnabledBlock(NO);
                //self.yb_browserToolBarHiddenBlock(YES);
                
                _isGestureInteraction = YES;
            }
        }
        
        // CHNAGE
        if (_isGestureInteraction) {
            self.mainContentView.center = point;
            CGFloat scale = 1 - ABS(point.y - self->_gestureInteractionStartPoint.y) / (self->_containerSize.height * 1.2);
            if (scale > 1) scale = 1;
            if (scale < 0.35) scale = 0.35;
            self.mainContentView.transform = CGAffineTransformMakeScale(scale, scale);
            
            CGFloat alpha = 1 - ABS(point.y - self->_gestureInteractionStartPoint.y) / (self->_containerSize.height * 1.1);
            if (alpha > 1) alpha = 1;
            if (alpha < 0) alpha = 0;
            //self.yb_browserChangeAlphaBlock(alpha, 0);
        }
    }
}

- (void)restoreGestureInteractionWithDuration:(NSTimeInterval)duration {
    //self.yb_browserChangeAlphaBlock(1, duration);
    
    void (^animations)(void) = ^{
        self.mainContentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.mainContentView.center = CGPointMake(self->_containerSize.width / 2, self->_containerSize.height / 2);
        self.mainContentView.transform = CGAffineTransformIdentity;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        //self.yb_browserScrollEnabledBlock(YES);
        //self.yb_browserToolBarHiddenBlock(NO);
        
        self.mainContentView.userInteractionEnabled = YES;
        self.mainContentView.scrollEnabled = YES;
        
        self->_gestureInteractionStartPoint = CGPointZero;
        self->_isGestureInteraction = NO;
        
       // [self cutImage];
    };
    if (duration <= 0) {
        animations();
        completion(NO);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}

//MARK:- UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect imageViewFrame = self.mainImageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight)
        imageViewFrame.origin.y = 0;
    else
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    if (width > sWidth)
        imageViewFrame.origin.x = 0;
    else
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    self.mainImageView.frame = imageViewFrame;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self cutImage];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    _isZooming = YES;
    //[self hideTailoringImageView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    _isZooming = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDragging = YES;
    //[self hideTailoringImageView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isDragging = NO;
}

//MARK:- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
