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

@property (nonatomic, copy) void (^mxBrowserCellDismissBlock)(void);

@end

NS_ASSUME_NONNULL_END
