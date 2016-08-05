# SYQRCodeDemo

SYQRCode:仿微信二维码扫描

### Latest
* 修复bug，优化实现和用户体验，更加简单易用（新增类似微信的打开动画效果）
* 添加新的类，拆分view
* 使用时直接拖动SYQRCodeViewController文件夹到工程里面即可
* 7.0及以上系统：如果只是简单的扫描二维码不需要添加第三方库，移除ZXingObjC即可

### New

- 支持读取图片二维码；

	需要支持iOS 7及以上系统则需依赖<a href="https://github.com/TheLevelUp/ZXingObjC">ZXingObjC</a>

	iOS >= 8.0，直接采用系统的即可；

- 支持开启闪光灯
- 支持生成二维码图片



### Introduction:基于<a href="https://github.com/reesun1130/SYQRCodeDemo">SYQRCodeDemo</a>





![intro png](https://github.com/sauchye/SYQRCodeDemo/raw/master/intro.PNG)



### Example：将SYQRCodeViewController拖入工程即可使用

``` objective-c
NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
//生成
CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
[qrFilter setValue:stringData forKey:@"inputMessage"];
[qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];

UIColor *onColor = [UIColor whiteColor];
UIColor *offColor = [UIColor darkGrayColor];

//上色
CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                   keysAndValues:
                         @"inputImage",qrFilter.outputImage,
                         @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                         @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                         nil];

CIImage *qrImage = colorFilter.outputImage;

//绘制
CGSize size = CGSizeMake(width, width);
CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
UIGraphicsBeginImageContext(size);
CGContextRef context = UIGraphicsGetCurrentContext();
CGContextSetInterpolationQuality(context, kCGInterpolationNone);
CGContextScaleCTM(context, 1.0, -1.0);
CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
_codeImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();

CGImageRelease(cgImage);
```
