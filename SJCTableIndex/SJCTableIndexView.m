//
//  SJCTableIndexView.m
//  Yehwang
//
//  Created by Yehwang on 2020/12/23.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCTableIndexView.h"
#import "SJCTableIndexIndicateView.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>

@protocol BXLTableViewScrollObserverDelegate<NSObject>
- (void)BXLTableViewScrollObserverDidDetectScrollToSection:(NSInteger)section;
@end

@interface BXLTableViewScrollObserver : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id <BXLTableViewScrollObserverDelegate> observerDelegate;
- (void)observerTableView:(UITableView *)tableView;
@end

static NSString *const kIndexTableViewContentOffsetObserverKey = @"contentOffset";

@implementation BXLTableViewScrollObserver

- (void)observerTableView:(UITableView *)tableView {
    [_tableView removeObserver:self forKeyPath:kIndexTableViewContentOffsetObserverKey];
    [tableView addObserver:self forKeyPath:kIndexTableViewContentOffsetObserverKey options:NSKeyValueObservingOptionNew context:nil];
    _tableView = tableView;
}
- (void)dealloc {
    [_tableView removeObserver:self forKeyPath:kIndexTableViewContentOffsetObserverKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kIndexTableViewContentOffsetObserverKey]) {
        UITableView *tableView = (id)object;
        NSInteger section = [tableView indexPathsForVisibleRows].firstObject.section;
        if ([_observerDelegate respondsToSelector:@selector(BXLTableViewScrollObserverDidDetectScrollToSection:)]) {
            [_observerDelegate BXLTableViewScrollObserverDidDetectScrollToSection:section];
        }
    }
}
@end

@implementation UITableViewIndexConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexViewRightpMargin = 2;
        _indexViewItemSpace = 2;
        _normalTextColor = [UIColor grayColor];
        _selectedBgColor = [UIColor darkGrayColor];
        _selectedTextColor = [UIColor whiteColor];
        _dynamicSwitch = YES;
        _normalTextFont = [UIFont systemFontOfSize:12];
        _indicateViewBgColor = [UIColor grayColor];
    }
    return self;
}
@end

CGFloat const kIndexViewWidth = 16.0;

@interface SJCTableIndexView()<CAAnimationDelegate,BXLTableViewScrollObserverDelegate>{
    BOOL _isTouch;
}

@property (nonatomic, copy) NSString *currentSelectedString;

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) CAShapeLayer *middleViewMaskLayer;

@property (nonatomic, strong) NSMutableArray <UILabel
 *>*textLabelsArray;
@property (nonatomic, strong) NSMutableArray <UILabel
*>*dotLabelsArray;
@property (nonatomic, strong) SJCTableIndexIndicateView *indicateView;
@property (nonatomic, strong) BXLTableViewScrollObserver *tableViewOberrver;
@end

@implementation SJCTableIndexView

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.configuration.indexViewItemSpace = 2.0;
        [self _resetUI];
        [self _addGesture];
    }
    return self;
}

#pragma mark - Custom Accessors
- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = [titles copy];
    [self _resetUI];
}

#pragma mark - Private

- (void)_addGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureAction:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureAction:)];
    [self addGestureRecognizer:panGesture];
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.middleView.frame = self.bounds;
    CGFloat top = [self getFirstTextTopPadding];
    CGFloat x = (self.frame.size.width - kIndexViewWidth) / 2.0;
    for (UILabel *label in self.textLabelsArray) {
        NSUInteger index = [self.textLabelsArray indexOfObject:label];

        label.frame = CGRectMake(x, top +(kIndexViewWidth + self.configuration.indexViewItemSpace)*index, kIndexViewWidth, kIndexViewWidth);
        UILabel *dotLabel = [self.dotLabelsArray objectAtIndex:index];
        dotLabel.frame = CGRectMake(x, top +(kIndexViewWidth + self.configuration.indexViewItemSpace)*index, kIndexViewWidth, kIndexViewWidth);
    }
}

- (void)_resetUI {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.textLabelsArray = @[].mutableCopy;
    self.dotLabelsArray = @[].mutableCopy;

    self.middleView = [[UIView alloc] initWithFrame:self.bounds];
    self.middleView.backgroundColor = self.configuration.selectedBgColor;
    
    self.middleViewMaskLayer = [CAShapeLayer layer];
    self.middleViewMaskLayer.path = [self _getMaskLayerPathRef];
    self.middleView.layer.mask = self.middleViewMaskLayer;
    self.middleView.userInteractionEnabled  = NO;

    for (NSString *string in _titles) {
        UILabel *label = [UILabel new];
        label.text = string;
        label.userInteractionEnabled  = NO;
        label.font = self.configuration.normalTextFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = self.configuration.normalTextColor;
        [self.textLabelsArray addObject:label];
        [self addSubview:label];
        // 两组label 达到颜色切换效果。
        UILabel *dotLabel = [UILabel new];
        dotLabel.text = string;
        dotLabel.userInteractionEnabled  = NO;

        dotLabel.font = self.configuration.normalTextFont;
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.textColor = self.configuration.selectedTextColor;
        [self.dotLabelsArray addObject:dotLabel];
        [self.middleView addSubview:dotLabel];
        
        if ([string isEqualToString:UITableViewIndexSearch]) {
            label.text = @"";
            [label.layer addSublayer:[self searchLayer]];
            dotLabel.text = @"";
            [dotLabel.layer addSublayer:[self searchLayer]];
        }
    }
    
    [self addSubview:self.middleView];
    [self setNeedsLayout];
}

- (CGPathRef)_getMaskLayerPathRef {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[self _getSelectedLabelFrame] cornerRadius:kIndexViewWidth/2.0];
    [path closePath];
    return path.CGPath;
}

- (void)_refrshUI:(BOOL)animation {
    if (animation && self.configuration.dynamicSwitch) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.values = @[(id)self.middleViewMaskLayer.path,
                             (id)[self _getMaskLayerPathRef]];
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.delegate = self;
        [self.middleViewMaskLayer addAnimation:animation forKey:@"dot_move_animation"];
        self.middleView.layer.mask = self.middleViewMaskLayer;
    }else{
        self.middleViewMaskLayer.path = [self _getMaskLayerPathRef];
        self.middleView.layer.mask = self.middleViewMaskLayer;
    }
}

- (CGRect)_getSelectedLabelFrame {
    for (UILabel *label in _textLabelsArray) {
        if ([label.text isEqualToString:_currentSelectedString]) {
            return label.frame;
        }
    }
    return CGRectZero;
}

- (CGFloat)getFirstTextTopPadding {
    if (!_titles || _titles.count == 0) {
        return 0;
    }
    CGFloat height = self.frame.size.height;
    CGFloat textTotalHeight = _titles.count * kIndexViewWidth + (_titles.count - 1) * self.configuration.indexViewItemSpace;
    return (height - textTotalHeight) / 2.0;
}

- (CAShapeLayer *)searchLayer {
    CGFloat radius = kIndexViewWidth / 4;
    CGFloat margin = kIndexViewWidth / 4;
    CGFloat start = radius * 2.5 + margin;
    CGFloat end = radius + sin(M_PI_4) * radius + margin;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(start, start)];
    [path addLineToPoint:CGPointMake(end, end)];
    [path addArcWithCenter:CGPointMake(radius + margin, radius + margin) radius:radius startAngle:M_PI_4 endAngle:2 * M_PI + M_PI_4 clockwise:YES];
    [path closePath];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = self.configuration.normalTextColor.CGColor;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.lineWidth = kIndexViewWidth / 12;
    layer.path = path.CGPath;
    return layer;
}

- (void)_updateCurrentSelectedString:(NSString *)selectedString
                          animation:(BOOL) animation {
    if ([_currentSelectedString isEqualToString:selectedString]) {
        return;
    }
    if (selectedString.length > 0
        && ![selectedString isEqualToString:UITableViewIndexSearch]) {
        _currentSelectedString = selectedString;
        self.middleView.hidden = NO;
        [self _refrshUI:animation];
    }else{
        _currentSelectedString = nil;
        self.middleView.hidden = YES;
    }
}

#pragma mark - Public

- (void)observeTableViewScroll:(UITableView *)tableView {
    [self.tableViewOberrver observerTableView:tableView];
}

#pragma mark - Actions

- (void)_gestureAction:(UIGestureRecognizer *)gesture {
    UILabel *locatedLabel = [self _getTouchLocateLabel:gesture];
    _isTouch = YES;
    if (locatedLabel
        && (![locatedLabel.text isEqualToString:_currentSelectedString] || !_currentSelectedString)) {
       
        NSString *selectedString = locatedLabel.text;
        if (selectedString.length == 0) {
            selectedString = UITableViewIndexSearch;
        }
        
        [self _updateCurrentSelectedString:selectedString animation:NO];

        if ([selectedString isEqualToString:UITableViewIndexSearch]) {
            [self.indicateView dismissWithAnimation:YES];
        }else{
            CGPoint center = locatedLabel.center;
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [self showIndicateViewInAnchorPoint:[self convertPoint:center toView:window]];
        }
        if ([_delegate respondsToSelector:@selector(SJCTableIndexViewDidClickIndex:)]) {
            [_delegate SJCTableIndexViewDidClickIndex:selectedString];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateFailed
        || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.indicateView dismissWithAnimation:YES];
         _isTouch = NO;
    }
}

- (UILabel *)_getTouchLocateLabel:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    for (UILabel *label in _textLabelsArray) {
        if (point.y <= (label.frame.origin.y + label.frame.size.height + self.configuration.indexViewItemSpace) && point.y >= label.frame.origin.y) {
            return label;
        }
    }
    UILabel *label = _textLabelsArray.firstObject;
    if (point.y > label.frame.origin.y + label.frame.size.height + self.configuration.indexViewItemSpace) {
        label = _textLabelsArray.lastObject;
    }
    return label;
}

- (void)showIndicateViewInAnchorPoint:(CGPoint) point {
    self.indicateView.backgroundColor = self.configuration.indicateViewBgColor;
    [self.indicateView updateWithAnchorPoint:point text:_currentSelectedString];
    
    if (@available(iOS 10.0, *)) {
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    } else {
        AudioServicesPlaySystemSound(1519);
    }
}
#pragma mark - delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self _refrshUI:NO];
    [self.middleViewMaskLayer removeAnimationForKey:@"dot_move_animation"];
}

- (void)BXLTableViewScrollObserverDidDetectScrollToSection:(NSInteger)section {
    if (_isTouch) return;
    
    NSMutableArray *titles = self.titles.mutableCopy;
    [titles removeObject:UITableViewIndexSearch];
    NSString *string = nil;
    if (section < titles.count) {
        string = titles[section];
    }
    if (_tableViewOberrver.tableView.contentOffset.y <= 0) {
        string = nil;
    }
    [self _updateCurrentSelectedString:string animation:YES];
}
#pragma mark - Lazy Load
- (SJCTableIndexIndicateView *)indicateView {
    if (!_indicateView) {
        _indicateView = [[SJCTableIndexIndicateView alloc] initWithFrame:CGRectZero];
    }
    return _indicateView;
}

- (BXLTableViewScrollObserver *)tableViewOberrver {
    if (!_tableViewOberrver) {
        _tableViewOberrver = [BXLTableViewScrollObserver new];
        _tableViewOberrver.observerDelegate = self;
    }
    return _tableViewOberrver;
}
#pragma mark - Other




@end
