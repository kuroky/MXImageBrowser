//
//  MXImageContentView.h
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXImageContentView : UICollectionView

/**
 dismiss browser
 */
@property (nonatomic, copy) void (^mxContentDismissBlock)(void);

@property (nonatomic, weak) UIPageControl *pageControl;

- (void)mx_reloadData:(NSArray <NSString *> *)list;

@end

NS_ASSUME_NONNULL_END
