//
//  ViewController.m
//  SYQRCodeDemo
//
//  Created by ree.sun on 15-1-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#define kTipsAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]
#define SCREEN_FRAME [UIScreen mainScreen].bounds


#import "ViewController.h"
#import "SYQRCodeViewController.h"
#import <ZXingObjC/ZXingObjC.h>

static CGFloat const width = 200.0;
static NSString * const text = @"http://sauchye.com";

@interface ViewController () <UIActionSheetDelegate>
@property (strong, nonatomic)  UIImage *codeImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
    }
    
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Example";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
 
    self.imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress)];
    [self.imageView addGestureRecognizer:press];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 生成二维码
- (void)longPress
{
    // warning iOS 9.1 Beta 2 bug
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫描二维码", @"保存二维码", nil];
    [sheet showInView:self.view];
}

- (IBAction)generateAction:(id)sender
{
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

    
    if (_codeImage != nil) {
        
        self.imageView.image = _codeImage;
        
    }else{
        kTipsAlert(@"字符串不合法");
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"success";
    if (!error) {
        kTipsAlert(@"保存成功");
    }else{
        message = [error description];
    }
}



#pragma mark - 扫描 读取

- (IBAction)scanoAction {
    __weak ViewController *weakSelf = self;
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc) {
        kTipsAlert(@"Failed");
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc) {
        kTipsAlert(@"Cancle");
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:qrcodevc animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        [self scanoAction];
    }else if(buttonIndex == 1){
        UIImageWriteToSavedPhotosAlbum(self.codeImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }else{
        return;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}



@end
