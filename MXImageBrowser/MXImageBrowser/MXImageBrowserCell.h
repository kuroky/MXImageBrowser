//
//  MXImageBrowserCell.h
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXImageBrowserCell : UICollectionViewCell

/**
 dismiss cell
 */
@property (nonatomic, copy) void (^mxBrowserCellDismissBlock)(void);

/**
 是否允许其他cell滑动
 */
@property (nonatomic, copy) void (^mxBrowserCellScrollEnable)(BOOL enable);

- (void)configWithImageUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
