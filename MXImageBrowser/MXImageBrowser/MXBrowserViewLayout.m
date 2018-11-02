//
//  MXBrowserViewLayout.m
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import "MXBrowserViewLayout.h"

@interface MXBrowserViewLayout ()

@end

@implementation MXBrowserViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.distanceBetweenPages = 20;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGSize size = self.collectionView.bounds.size;
    self.itemSize = CGSizeMake(size.width, size.height);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttsArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat halfWidth = self.collectionView.bounds.size.width / 2.0;
    CGFloat centerX = self.collectionView.contentOffset.x + halfWidth;
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(obj.center.x + (obj.center.x - centerX) / halfWidth * self.distanceBetweenPages / 2, obj.center.y);
    }];
    return layoutAttsArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
