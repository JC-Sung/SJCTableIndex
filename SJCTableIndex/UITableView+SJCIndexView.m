//
//  UITableView+SJCIndexView.m
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "UITableView+SJCIndexView.h"
#import <objc/runtime.h>

@implementation UITableView (SJCIndexView)
@dynamic sjc_indexView,sjc_indexArray,sjc_configuration;

+ (void)load {
    [self swizzledSelector:@selector(indexView_layoutSubviews) originalSelector:@selector(layoutSubviews)];
}

+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)indexView_layoutSubviews {
    [self indexView_layoutSubviews];
    if (self.sjc_indexArray.count > 0) {
        [self.superview addSubview:self.indexView];
        CGFloat indexViewHeight = [self index_getIndexViewHeight];
        CGFloat indexViewWidth = kIndexViewWidth;
        CGFloat top = self.center.y - indexViewHeight/2 - self.sjc_configuration.indexViewTopMargin;
        CGFloat left = self.frame.size.width + self.frame.origin.x - kIndexViewWidth - self.sjc_configuration.indexViewRightpMargin;
        self.indexView.frame = CGRectMake(left, top, indexViewWidth, indexViewHeight);
        [self.indexView setNeedsLayout];
    }else{
        [self.indexView removeFromSuperview];
    }
}

- (CGFloat)index_getIndexViewHeight {
    return self.sjc_configuration.indexViewItemSpace * (self.sjc_indexArray.count - 1) + kIndexViewWidth * self.sjc_indexArray.count;
}

static char kConfigurationKey;
- (UITableViewIndexConfig *)sjc_configuration {
   UITableViewIndexConfig *config = objc_getAssociatedObject(self, &kConfigurationKey);
    if (!config && self.sjc_indexArray.count > 0) {
        config = [UITableViewIndexConfig new];
        objc_setAssociatedObject(self, &kConfigurationKey, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return config;
}

- (void)setSjc_configuration:(UITableViewIndexConfig *)sjc_configuration{
    objc_setAssociatedObject(self, &kConfigurationKey, sjc_configuration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char kIndexViewChar;
- (SJCTableIndexView *)indexView {
    SJCTableIndexView *indexView = objc_getAssociatedObject(self, &kIndexViewChar);
    if (!indexView && self.sjc_indexArray.count > 0) {
        indexView = [SJCTableIndexView new];
        indexView.configuration = self.sjc_configuration;
        objc_setAssociatedObject(self, &kIndexViewChar, indexView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return indexView;
}

static char kIndexArrayChar;
- (void)setSjc_indexArray:(NSArray<NSString *> *)sjc_indexArray{
    objc_setAssociatedObject(self, &kIndexArrayChar, sjc_indexArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (sjc_indexArray.count > 0) {
        self.indexView.titles = sjc_indexArray;
        self.indexView.delegate = (id<SJCTableIndexViewDelegate>) self;
        [self.indexView observeTableViewScroll:self];
        [self addIndexView];
    }else{
        self.indexView.delegate = nil;
        [self removeIndexView];
    }
}


- (NSArray<NSString *> *)sjc_indexArray {
    return objc_getAssociatedObject(self, &kIndexArrayChar);
}

- (void)addIndexView {
    [self.superview addSubview:self.indexView];
}

- (void)removeIndexView {
    [self.indexView removeFromSuperview];
}

- (void)SJCTableIndexViewDidClickIndex:(NSString *)indexString {
    NSInteger index = [self.sjc_indexArray indexOfObject:indexString];
    NSInteger section = 0;
    if ([indexString isEqualToString:UITableViewIndexSearch]
        && index == 0) {
        section = 0;
    }else{
        section = index;
        if ([self.sjc_indexArray.firstObject isEqualToString:UITableViewIndexSearch]) {
            section--;
        }
    }
    
    if (section >= self.numberOfSections) {
        section = self.numberOfSections - 1;
    }

    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


@end
