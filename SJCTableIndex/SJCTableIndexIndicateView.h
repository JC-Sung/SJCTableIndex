//
//  SJCTableIndexIndicateView.h
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJCTableIndexIndicateView : UIView

@property (nonatomic, copy, readonly) NSString *text;

- (void)dismissWithAnimation:(BOOL)animation;

- (void)updateWithAnchorPoint:(CGPoint)anchorPoint
                         text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
