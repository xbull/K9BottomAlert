//
//  K9BottomAlert.m
//  GetZ
//
//  Created by K999999999 on 16/8/25.
//  Copyright © 2016年 makeupopular.com. All rights reserved.
//

#import "K9BottomAlert.h"
#import "WXWaveView.h"

@interface K9BottomAlert () <UIGestureRecognizerDelegate>

@property (nonatomic)           BOOL                    hasAppeared;
@property (nonatomic)           BOOL                    willDismiss;
@property (nonatomic, strong)   WXWaveView              *k9WaveView;
@property (nonatomic, strong)   UITapGestureRecognizer  *k9TapGesture;
@property (nonatomic, strong)   UIPanGestureRecognizer  *k9PanGesture;

@end

@implementation K9BottomAlert

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.hasAppeared = NO;
    self.willDismiss = NO;
    [self k9ConfigContentView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self k9PlayAppearAnimation];
}

#pragma mark - Config Views

- (void)k9ConfigContentView {
    
    if (self.contentView.superview != nil) {
        return;
    }
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view).with.offset(self.contentHeight);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(self.contentHeight);
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint point = [touch locationInView:self.view];
    if(CGRectContainsPoint(self.contentView.frame, point)
       && [gestureRecognizer isEqual:self.k9TapGesture] ){
        
        return NO;
    }
    return YES;
}

#pragma mark - Action Methods

- (void)k9OnTapGesture:(UITapGestureRecognizer *)gesture {
    
    if (self.willDismiss) {
        return;
    }
    CGPoint point = [gesture locationInView:self.view];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self dismissBottomAlert:nil];
    }
}

- (void)k9OnPanGesture:(UIPanGestureRecognizer *)gesture {
    
    if (self.willDismiss) {
        return;
    }
    CGPoint point = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            
            if (point.y > 0.f){
                
                if (velocity.y > 1400.f) {
                    
                    [self dismissBottomAlert:nil];
                } else {
                    
                    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                        
                        make.bottom.equalTo(self.view).with.offset(point.y);
                    }];
                    
                    if (self.animationType & K9BottomAnimationTypeScale) {
                        CGFloat scale = .96f + (1.f - .96f) / self.contentHeight * point.y;
                        [self k9RefreshAnimation3DScale:scale];
                    }
                    
                    if (self.animationType & K9BottomAnimationTypeWave) {
                        [self.k9WaveView wave];
                        self.k9WaveView.frame = CGRectMake(self.k9WaveView.frame.origin.x, self.contentView.frame.origin.y - 5.f, self.k9WaveView.frame.size.width, self.k9WaveView.frame.size.height);
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            if (point.y > self.contentHeight * .8f) {
                
                [self dismissBottomAlert:nil];
            } else {
                
                [UIView animateWithDuration:.2f animations:^{
                    
                    if (self.animationType & K9BottomAnimationTypeScale) {
                        [self k9RefreshAnimation3DScale:.96f];
                    }
                    
                    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                        
                        make.bottom.equalTo(self.view);
                    }];
                    
                    if (self.animationType & K9BottomAnimationTypeWave) {
                        self.k9WaveView.frame = CGRectMake(self.k9WaveView.frame.origin.x, self.contentView.frame.origin.y - 5.f, self.k9WaveView.frame.size.width, self.k9WaveView.frame.size.height);
                    }
                } completion:^(BOOL finished) {
                    
                    if (self.animationType & K9BottomAnimationTypeWave) {
                        [self.k9WaveView stop];
                    }
                }];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Public Methods

- (void)k9PlayDismissAnimation:(void (^)(void))completion {
    
    self.willDismiss = YES;
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view).with.offset(self.contentHeight);
    }];
    
    [UIView animateWithDuration:.3f animations:^{
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private Methods

- (void)k9RegisterGesture {
    
    if (self.dismissType & K9BottomDismissTypeTap) {
        [self.view addGestureRecognizer:self.k9TapGesture];
    }
    
    if (self.dismissType & K9BottomDismissTypePan) {
        [self.view addGestureRecognizer:self.k9PanGesture];
    }
}

- (void)k9PlayAppearAnimation {
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hasAppeared = YES;
        [self k9RegisterGesture];
    }];
}

- (void)k9RefreshAnimation3DScale:(CGFloat)scale {
    
    UIView *rootVCView  = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.f / -900.f;
    t1 = CATransform3DScale(t1, scale, scale, 1.f);
    t1 = CATransform3DTranslate(t1, 0.f, self.view.frame.size.height * (-.01f), 0.f);
    
    [rootVCView.layer setTransform:t1];
}

#pragma mark - Setters

- (void)setContentHeight:(CGFloat)contentHeight {
    
    _contentHeight = contentHeight;
    if (self.hasAppeared) {
        
        [UIView animateWithDuration:.3f animations:^{
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(contentHeight);
            }];
        }];
    } else {
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).with.offset(contentHeight);
            make.height.mas_equalTo(contentHeight);
        }];
    }
}

#pragma mark - Getters

- (UIView *)contentView {
    
    if (!_contentView) {
        
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (WXWaveView *)k9WaveView {
    
    if (self.isViewLoaded && !_k9WaveView) {
        
        _k9WaveView = [WXWaveView addToView:self.view withFrame:CGRectMake(0.f, (self.view.frame.size.height - self.contentHeight - 5.f), CGRectGetWidth(self.view.frame), 5.f)];
    }
    return _k9WaveView;
}

- (UITapGestureRecognizer *)k9TapGesture {
    
    if (!_k9TapGesture) {
        
        _k9TapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(k9OnTapGesture:)];
        _k9TapGesture.delegate = self;
    }
    return _k9TapGesture;
}

- (UIPanGestureRecognizer *)k9PanGesture {
    
    if (!_k9PanGesture) {
        
        _k9PanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(k9OnPanGesture:)];
        _k9PanGesture.delegate = self;
    }
    return _k9PanGesture;
}

@end

@implementation UIViewController (K9BottomAlert)

#pragma mark - Public Methods

- (void)presentBottomAlert:(K9BottomAlert *)bottomAlert completion:(void (^)(void))completion {
    
    if (!bottomAlert.view.backgroundColor) {
        bottomAlert.view.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.4f];
    }
    
    if (bottomAlert.animationType & K9BottomAnimationTypeScale) {
        
        UIView *rootVCView  = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [rootVCView.layer setTransform:[self k9FirstTransform]];
            
        } completion:nil];
    }
    
    [UIView animateWithDuration:.1f delay:.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self presentViewController:bottomAlert animated:NO completion:completion];
        
    } completion:nil];
}

- (void)dismissBottomAlert:(void (^)(void))completion {
    
    if ([self isKindOfClass:[K9BottomAlert class]]) {
        
        K9BottomAlert *bottomAlert = (K9BottomAlert *)self;
        [bottomAlert k9PlayDismissAnimation:^{
            if (bottomAlert.animationType & K9BottomAnimationTypeScale) {
                
                UIView *rootVCView  = [UIApplication sharedApplication].keyWindow.rootViewController.view;
                
                [UIView animateWithDuration:.3f animations:^{
                    [rootVCView.layer setTransform:CATransform3DIdentity];
                    [self dismissViewControllerAnimated:NO completion:completion];
                }];
            } else {
                
                [self dismissViewControllerAnimated:NO completion:completion];
            }
        }];
    } else {
        
        [self dismissViewControllerAnimated:NO completion:completion];
    }
}

#pragma mark - Private Methods

- (CATransform3D )k9FirstTransform {
    
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.f / -900.f;
    t1 = CATransform3DScale(t1, .96f, .96f, 1.f);
    t1 = CATransform3DTranslate(t1, 0.f, self.view.frame.size.height * (-.01f), 0.f);
    return t1;
}

@end
