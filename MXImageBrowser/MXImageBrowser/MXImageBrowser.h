//
//  MXImageBrowser.h
//  MXImageBrowser
//
//  Created by kuroky on 2018/11/1.
//  Copyright © 2018 Kuroky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXImageBrowser : UIViewController

@property (nonatomic, weak) UIView *indexView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSArray <NSString *> *imageUrls;

@end

NS_ASSUME_NONNULL_END
