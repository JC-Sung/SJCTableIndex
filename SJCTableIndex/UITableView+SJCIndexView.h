//
//  UITableView+SJCIndexView.h
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCTableIndexView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (SJCIndexView)
@property (nonatomic, strong, readonly) SJCTableIndexView *sjc_indexView;
@property (nonatomic, strong) NSArray <NSString *> *sjc_indexArray;
@property (nonatomic, strong) UITableViewIndexConfig *sjc_configuration;
@end

NS_ASSUME_NONNULL_END
