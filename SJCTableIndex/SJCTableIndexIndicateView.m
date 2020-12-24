//
//  SJCTableIndexIndicateView.m
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCTableIndexIndicateView.h"

static const CGFloat kDiameter = 44;
static const CGFloat kPaddingToAnchorPoint = 25;

@interface SJCTableIndexIndicateView()

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UILabel *textLabel;

@end
@implementation SJCTableIndexIndicateView


- (CGRect)getFrameInWindowByAnchorPoint:(CGPoint)anchorPoint {
    return CGRectMake(anchorPoint.x - kDiameter/2.0 * (1+sqrtf(2)) - kPaddingToAnchorPoint, anchorPoint.y - kDiameter / 2.0, kDiameter/2.0 * (1+sqrtf(2)), kDiameter);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.maskLayer = [CAShapeLayer layer];
        self.maskLayer.path = [self getPathref];
        self.layer.mask = self.maskLayer;
        
        self.textLabel = [UILabel new];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont boldSystemFontOfSize:27];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(0, 0, kDiameter, kDiameter);
}

- (CGPathRef)getPathref {
    CGPoint arcCenter = CGPointMake(kDiameter / 2.0, kDiameter / 2.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:kDiameter / 2.0 startAngle:M_PI * 1 / 4 endAngle:2*M_PI - M_PI / 4 clockwise:YES];
    [path addLineToPoint:CGPointMake((1 + sqrtf(2)) * kDiameter/2, kDiameter / 2.0)];
    [path closePath];
    return path.CGPath;
}

- (void)updateWithAnchorPoint:(CGPoint)anchorPoint
                         text:(NSString *)text {
    _textLabel.text = text;
    _anchorPoint = anchorPoint;
    [self updateFrame];
    [self showInWindow];
}

- (void)updateFrame {
    self.frame = [self getFrameInWindowByAnchorPoint:_anchorPoint];
}

- (void)showInWindow {
    self.alpha = 1;
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    [keyWindow addSubview:self];
}

- (void)dismissWithAnimation:(BOOL)animation {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
