//
//  MXImageContentView.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXImageContentView.h"
#import "MXImageBrowserCell.h"
#import "MXBrowserViewLayout.h"

static NSString *const kMXImageContentViewCellId   =   @"MXImageContentViewCellId";

@interface MXImageContentView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray <NSString *> *list;

@end

@implementation MXImageContentView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame collectionViewLayout:[MXBrowserViewLayout new]];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.delegate = self;
    self.dataSource = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self registerClass:[MXImageBrowserCell class] forCellWithReuseIdentifier:kMXImageContentViewCellId];
}

- (void)mx_reloadData:(NSArray <NSString *> *)list {
    self.list = list;
    [self reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

//MARK:- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MXImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMXImageContentViewCellId forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor brownColor];
    __weak typeof(self) weak_self = self;
    cell.mxBrowserCellDismissBlock = ^{
        weak_self.mxContentDismissBlock ? weak_self.mxContentDismissBlock() : nil;
    };
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexF = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSUInteger index = (NSUInteger)(indexF + 0.5);
    self.pageControl.currentPage = index;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    // When the hit-test view is 'UISlider', set '_scrollEnabled' to 'NO', avoid gesture conflicts.
    self.scrollEnabled = ![view isKindOfClass:UISlider.class];
    return view;
}

@end
