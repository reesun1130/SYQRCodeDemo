//
//  SYQRCodeOverlayView.h
//  UserCarDealer
//
//  Created by autohome on 16/8/5.
//  Copyright © 2016年 autohome. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define kIOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

static const float kLineMinY = 121;
static const float kLineMaxY = 380;
static const float kReaderViewWidth = 259;
static const float kReaderViewHeight = 259;
static const float BTN_TAG = 100000;

@interface SYQRCodeOverlayView : UIView

@property (nonatomic, copy) void (^SYQRCodeOverlayViewBtnAction) (UIButton *);

- (instancetype)initWithFrame:(CGRect)frame
                   basedLayer:(CALayer *)layer;

@end
