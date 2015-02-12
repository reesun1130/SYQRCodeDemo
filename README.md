# SYQRCodeDemo

SYQRCode:低仿微信二维码扫描，IOS原生API，需要IOS7.0及以上系统支持。简单易用，使用block做回调处理。

用法：
    
    SYQRCodeViewController *syqrc = [[SYQRCodeViewController alloc] init];
    syqrc.SYQRCodeSuncessBlock = ^(NSString *qrString){
        
        self.saomiaoLabel.text = qrString;
    
    };
    
    syqrc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrc){
    
        self.saomiaoLabel.text = @"扫描取消~";
        [aqrc dismissViewControllerAnimated:YES completion:nil];
    
    };
    [self presentViewController:syqrc animated:YES completion:nil];

# 效果如下：
 ![image](https://github.com/reesun1130/SYQRCodeDemo/raw/master/SYQRCodeDemo/syqrcode.png)
 
另附IOS7二维码生成方法：

- (UIImage *)makeQRCodeImage
{
    CIFilter *filter_qrcode = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter_qrcode setDefaults];
    
    NSData *data = [@"https://github.com/reesun1130" dataUsingEncoding:NSUTF8StringEncoding];
    [filter_qrcode setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter_qrcode outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    //大小控制
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    
    //颜色控制
    resized = [self imageBlackToTransparent:resized withRed:30 andGreen:191 andBlue:109];
    
    CGImageRelease(cgImage);

    return resized;
}

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
	UIImage *resized = nil;
	CGFloat width = image.size.width * rate;
	CGFloat height = image.size.height * rate;
	
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, quality);
	[image drawInRect:CGRectMake(0, 0, width, height)];
	resized = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resized;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
    {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

