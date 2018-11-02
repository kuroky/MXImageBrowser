//
//  MXImageBrowserCell.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXImageBrowserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Masonry.h"
#import "MXBrowserDefine.h"

@interface MXImageBrowserCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    CGSize _containerSize;
    BOOL _isZooming;
    BOOL _isDragging;
    BOOL _bodyIsInCenter;
    
    BOOL _isGestureInteraction;
    CGPoint _gestureInteractionStartPoint;
    
}

@property (nonatomic, strong) UIScrollView *mainContentView;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;

@end

@implementation MXImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        [self setupUI];
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
    self.progressLayer.strokeEnd = 0;
    _containerSize = self.frame.size;
    _gestureInteractionStartPoint = CGPointZero;
}

- (void)setupUI {
    [self.contentView addSubview:self.mainContentView];
    [self.mainContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(414);
        make.height.mas_equalTo(800);
    }];
    
    [self.mainContentView addSubview:self.mainImageView];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.leading.equalTo(self.mas_leading);
        //make.trailing.equalTo(self.mas_trailing);
        //make.top.equalTo(self.mas_top);
        //make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.mainContentView.mas_centerX);
        make.centerY.equalTo(self.mainContentView.mas_centerY);
        make.width.mas_equalTo(414);
        make.height.mas_equalTo(800);
    }];
    [self.layer addSublayer:self.progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.progressLayer.frame.origin.x > 0) {
        return;
    }
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
    CGRect frame = self.progressLayer.frame;
    frame.origin.x = center.x - CGRectGetWidth(frame) / 2.0f;
    frame.origin.y = center.y - CGRectGetHeight(frame) / 2.0f;
    self.progressLayer.frame = frame;
}

- (UIScrollView *)mainContentView {
    if (!_mainContentView) {
        _mainContentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _mainContentView.delegate = self;
        _mainContentView.showsHorizontalScrollIndicator = NO;
        _mainContentView.showsVerticalScrollIndicator = NO;
        _mainContentView.decelerationRate = UIScrollViewDecelerationRateFast;
        _mainContentView.maximumZoomScale = 1;
        _mainContentView.minimumZoomScale = 1;
        _mainContentView.alwaysBounceHorizontal = NO;
        _mainContentView.alwaysBounceVertical = NO;
        _mainContentView.layer.masksToBounds = NO;
        if (@available(iOS 11.0, *)) {
            _mainContentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainContentView;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.masksToBounds = YES;
    }
    return _mainImageView;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 40, 40);
        _progressLayer.cornerRadius = MIN(CGRectGetWidth(_progressLayer.bounds) / 2.0f, CGRectGetHeight(_progressLayer.bounds) / 2.0f);
        _progressLayer.lineWidth = 4;
        _progressLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:_progressLayer.cornerRadius - 7];
        _progressLayer.path = path.CGPath;
        _progressLayer.hidden = YES;
    }
    return _progressLayer;
}

- (CGFloat)maxWidth {
    static dispatch_once_t onceToken;
    static CGFloat width;
    dispatch_once(&onceToken, ^{
        width = [UIScreen mainScreen].scale * self.frame.size.width;
    });
    return width;
}

- (CGFloat)maxHeight {
    static dispatch_once_t onceToken;
    static CGFloat height;
    dispatch_once(&onceToken, ^{
        height = [UIScreen mainScreen].scale * self.frame.size.height;
    });
    return height;
}

- (void)configWithImageUrl:(NSString *)url {
    mx_Weakify(self)
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:url]
                          placeholderImage:nil
                                   options:SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//                                      if (strong_self.dismissing || !strong_self.view.window) {
//                                          strong_self.progressLayer.hidden = YES;
//                                          return;
//                                      }
                                      CGFloat progress = (receivedSize * 1.0f) / (expectedSize * 1.0f);
                                      if (0.0f >= progress || progress >= 1.0f) {
                                          mx_Weakself.progressLayer.hidden = YES;
                                          return;
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          mx_Weakself.progressLayer.hidden = NO;
                                          mx_Weakself.progressLayer.strokeEnd = progress;
                                      });
                                  }
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                     //NSLog(@"%@", NSStringFromCGSize(image.size));
                                     [mx_Weakself resizeView:image];
                                 }];
}

- (void)resizeView:(UIImage *)image {
    // 1024 * 768
    // 414 * 828
    
    CGFloat imgWidth = image.scale * image.size.width;
    CGFloat imgHeight = image.scale * image.size.height;
    CGFloat width = 0;
    CGFloat height = 0;
    if (imgWidth > imgHeight) {
        width = (imgWidth > self.maxWidth) ? self.maxWidth : imgWidth;
        height = width * imgHeight / imgWidth;
    }
    else {
        height = (imgHeight > self.maxHeight) ? self.maxHeight : imgHeight;
        width = height * imgWidth / imgHeight;
    }
    
    width = width / [UIScreen mainScreen].scale;
    height = height / [UIScreen mainScreen].scale;
    
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.mainImageView setNeedsLayout];
    //[self.mainImageView layoutIfNeeded];
    self.mainImageView.image = image;
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
                self.mxBrowserCellDismissBlock();
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
            //[self hideTailoringImageView];
            
            _gestureInteractionStartPoint = point;
            
            CGRect startFrame = self.mainContentView.frame;
            CGFloat anchorX = point.x / startFrame.size.width,
            anchorY = point.y / startFrame.size.height;
            self.mainContentView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
            self.mainContentView.userInteractionEnabled = NO;
            self.mainContentView.scrollEnabled = NO;
            
            self.mxBrowserCellScrollEnable(NO);
            //self.yb_browserToolBarHiddenBlock(YES);
            
            _isGestureInteraction = YES;
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
        self.mxBrowserCellScrollEnable(YES);
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
