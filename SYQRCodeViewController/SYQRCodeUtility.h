//
//  SYQRCodeUtility.h
//  SYQRCodeDemo
//
//  Created by ree.sun on 16/9/8.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define kIOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

static const float kLineMinY = 121;
static const float kLineMaxY = 380;
static const float kReaderViewWidth = 259;
static const float kReaderViewHeight = 259;

@interface SYQRCodeUtility : NSObject

+ (BOOL)canAccessAVCaptureDeviceForMediaType:(NSString *)mediaType;
+ (NSString *)readQRCodeImage:(UIImage *)imagePicked;
+ (UIImage *)generateQRCodeImage:(NSString *)strQRCode
                            size:(CGSize)size;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message;
+ (CGRect)getReaderViewBoundsWithSize:(CGSize)asize;
+ (CAKeyframeAnimation *)zoomOutAnimation;
+ (void)openSystemSettings;

@end
