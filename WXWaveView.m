//
//  WXWaveView.m
//
//  Created by WelkinXie on 16/4/20.
//  Copyright © 2016年 WelkinXie. All rights reserved.
//
//

#import "WXWaveView.h"

@interface WXWaveView ()

@property (assign, nonatomic) CGFloat offsetX;
@property (strong, nonatomic) CADisplayLink *waveDisplayLink;
@property (strong, nonatomic) CAShapeLayer *waveShapeLayer;

@end

@implementation WXWaveView

+ (instancetype)addToView:(UIView *)view withFrame:(CGRect)frame {
    WXWaveView *waveView = [[self alloc] initWithFrame:frame];
    [view addSubview:waveView];
    return waveView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self basicSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        [self basicSetup];
    }
    return self;
}

- (void)basicSetup {
    _angularSpeed = 2.f;
    _waveSpeed = 9.f;
    _waveTime = 1.5f;
    _waveColor = [UIColor whiteColor];
}

- (BOOL)wave {
    self.alpha = 1.f;
    if (self.waveShapeLayer.path) {
        return NO;
    }
    self.waveShapeLayer = [CAShapeLayer layer];
    self.waveShapeLayer.fillColor = self.waveColor.CGColor;
    self.waveDisplayLink.paused = NO;

    [self.layer addSublayer:self.waveShapeLayer];
    
    self.waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(currentWave)];
    [self.waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    if (self.waveTime > 0.f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.waveTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
    return YES;
}

- (void)currentWave {
    self.offsetX -= self.waveSpeed;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, height / 2);

    CGFloat y = 0.f;
    for (CGFloat x = 0.f; x <= width ; x++) {
        y = height * sin(0.01 * (self.angularSpeed * x + self.offsetX));
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGPathAddLineToPoint(path, NULL, width, height);
    CGPathAddLineToPoint(path, NULL, 0, height);
    CGPathCloseSubpath(path);
    
    self.waveShapeLayer.path = path;
    CGPathRelease(path);
}

- (void)stop
{
    [UIView animateWithDuration:1.5f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.waveDisplayLink invalidate];
        self.waveDisplayLink.paused = YES;
        self.waveDisplayLink = nil;
        self.waveShapeLayer.path = nil;
        self.alpha = 0.f;
        [self.waveDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }];
    
}

@end
