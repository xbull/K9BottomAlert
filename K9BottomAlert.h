//
//  K9BottomAlert.h
//  GetZ
//
//  Created by K999999999 on 16/8/25.
//  Copyright © 2016年 makeupopular.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// Subclass this Alert to add custom view to contentView
// Must set contentHeight before add subview to contentView

typedef NS_OPTIONS(NSUInteger, K9BottomAnimationType) {
    
    K9BottomAnimationTypeNone   = 1 << 0,
    K9BottomAnimationTypeScale  = 1 << 1,
    K9BottomAnimationTypeWave   = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, K9BottomDismissType) {
    
    K9BottomDismissTypeNone = 1 << 0,
    K9BottomDismissTypeTap  = 1 << 1,
    K9BottomDismissTypePan  = 1 << 2
};

@interface K9BottomAlert : UIViewController

@property (nonatomic)           K9BottomAnimationType   animationType;
@property (nonatomic)           K9BottomDismissType     dismissType;
@property (nonatomic)           CGFloat                 contentHeight;
@property (nonatomic, strong)   UIView                  *contentView;

- (void)k9PlayDismissAnimation:(void (^)(void))completion;

@end

@interface UIViewController (K9BottomAlert)

- (void)presentBottomAlert:(K9BottomAlert *)bottomAlert completion:(void (^)(void))completion;
- (void)dismissBottomAlert:(void (^)(void))completion;

@end
