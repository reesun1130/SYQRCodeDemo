//
//  SYQRCodeUtility.m
//  SYQRCodeDemo
//
//  Created by ree.sun on 16/9/8.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYQRCodeUtility.h"

@implementation SYQRCodeUtility

+ (BOOL)canAccessAVCaptureDeviceForMediaType:(NSString *)mediaType {
    __block BOOL canAccess = NO;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        dispatch_semaphore_t dis_sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            dispatch_semaphore_signal(dis_sema);
            canAccess = granted;
        }];
        dispatch_semaphore_wait(dis_sema, DISPATCH_TIME_FOREVER);
    }
    else if (status == AVAuthorizationStatusAuthorized) {
        canAccess = YES;
    }
    
    return canAccess;
}

#warning 原生API，读取图片二维码，iOS8+
//iOS8+
+ (NSString *)readQRCodeImage:(UIImage *)imagePicked {
    CIImage *qrcodeImage = [CIImage imageWithCGImage:imagePicked.CGImage];
    CIContext *qrcodeContext = [CIContext contextWithOptions:nil];
    
    //检测图片中的二维码，并设置检测精度为高
    CIDetector *qrcodeDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:qrcodeContext options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    //读取图片的qrcode特性
    NSArray *qrcodeFeatures = [qrcodeDetector featuresInImage:qrcodeImage];
    
    //返回的结果，只读取一条
    NSString *qrcodeResultString = nil;
    if (qrcodeFeatures && qrcodeFeatures.count > 0) {
        for (CIQRCodeFeature *qrcodeFeature in qrcodeFeatures) {
            if (qrcodeResultString && qrcodeResultString.length > 0) {
                break;
            }
            qrcodeResultString = qrcodeFeature.messageString;
        }
    }
    NSLog(@"%@",qrcodeResultString);
    
    return qrcodeResultString;
}

+ (UIImage *)generateQRCodeImage:(NSString *)strQRCode
                            size:(CGSize)size {
    if (!strQRCode || strQRCode.length == 0) {
        return nil;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    
    NSData *stringData = [strQRCode dataUsingEncoding:NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor whiteColor];
    UIColor *offColor = [UIColor darkGrayColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:@"inputImage",
                             qrFilter.outputImage, @"inputColor0",
                             [CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    //绘制
    CIImage *qrImage = colorFilter.outputImage;

    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return codeImage;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

+ (CGRect)getReaderViewBoundsWithSize:(CGSize)asize {
    return CGRectMake(kLineMinY / SCREEN_HEIGHT, ((SCREEN_WIDTH - asize.width) / 2.0) / SCREEN_WIDTH, asize.height / SCREEN_HEIGHT, asize.width / SCREEN_WIDTH);
}

+ (CAKeyframeAnimation *)zoomOutAnimation {
    CAKeyframeAnimation *animationLayer = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animationLayer.duration = 0.1;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animationLayer.values = values;
    
    return animationLayer;
}

#warning 使用openURL前请添加scheme：prefs
+ (void)openSystemSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kIOS8_OR_LATER ? UIApplicationOpenSettingsURLString : @"prefs:root"]];
}

@end
