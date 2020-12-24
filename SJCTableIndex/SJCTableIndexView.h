//
//  SJCTableIndexView.h
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewIndexConfig : NSObject
@property (nonatomic) CGFloat indexViewTopMargin; // default 0
@property (nonatomic) CGFloat indexViewRightpMargin; // default 2
@property (nonatomic) CGFloat indexViewItemSpace; // default 2

@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIFont *normalTextFont;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *selectedBgColor;
@property (nonatomic, strong) UIColor *indicateViewBgColor;
@property (nonatomic) BOOL dynamicSwitch; // default YES
@end

extern CGFloat const kIndexViewWidth;

@protocol SJCTableIndexViewDelegate<NSObject>
- (void)SJCTableIndexViewDidClickIndex:(NSString *)indexString;
@end

@interface SJCTableIndexView : UIView
@property (nonatomic, strong) UITableViewIndexConfig *configuration;
@property (nonatomic, copy, readonly) NSString *currentSelectedString;
@property (nonatomic, copy) NSArray <NSString *>*titles;
@property (nonatomic, weak) id<SJCTableIndexViewDelegate> delegate;

- (void)observeTableViewScroll:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
