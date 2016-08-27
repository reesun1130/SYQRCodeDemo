//
//  SYQRCodeOverlayView.h
//  SYQRCodeDemo
//
//  Created by ree.sun on 16/8/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
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

@interface SYQRCodeOverlayView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   basedLayer:(CALayer *)layer;

@end
