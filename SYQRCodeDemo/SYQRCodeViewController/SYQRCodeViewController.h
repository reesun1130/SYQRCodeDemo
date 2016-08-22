//
//  SYQRCodeViewController.h
//  SYQRCodeDemo
//
//  Created by ree.sun on 15-1-9.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>

@interface SYQRCodeViewController : UIViewController

/**SYQRCodeCancleBlock */
@property (nonatomic, copy) void (^SYQRCodeCancleBlock) (SYQRCodeViewController *);

/**SYQRCodeSuncessBlock */
@property (nonatomic, copy) void (^SYQRCodeSuncessBlock) (SYQRCodeViewController *, NSString *);

/**SYQRCodeFailBlock */
@property (nonatomic, copy) void (^SYQRCodeFailBlock) (SYQRCodeViewController *);

///**
// *  生成二维码图片
// *
// *  @param imageString 二维码内容
// *  @param size        尺寸
// *  @param logo        中间icon
// *  @param onColor     default white
// *  @param offColor    default black
// *
// *  @return UIImage
// */
//+ (UIImage *_Nullable)generateQRCodeImage:(NSString *_Nonnull)imageString
//                                     size:(CGSize)size;
//
//+ (UIImage *_Nullable)generateQRCodeImage:(NSString *_Nonnull)imageString
//                                     size:(CGSize)size
//                                     logo:(UIImage *_Nullable)logo;
//
//+ (UIImage *_Nullable)generateQRCodeImage:(NSString *_Nonnull)imageString
//                                     size:(CGSize)size
//                                     logo:(UIImage *_Nullable)logo
//                                fillColor:(UIColor *_Nullable)onColor;

@end
