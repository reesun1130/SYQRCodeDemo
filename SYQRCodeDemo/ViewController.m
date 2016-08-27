//
//  ViewController.m
//  SYQRCodeDemo
//
//  Created by ree.sun on 15-1-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#define kTipsAlert(_S_, ...) [[[UIAlertView alloc] initWithTitle:@"提示" \
message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] \
delegate:nil \
cancelButtonTitle:@"知道了" \
otherButtonTitles:nil] show] \

#import "ViewController.h"
#import "SYQRCodeViewController.h"
#import "ReadQRCodeViewController.h"

static NSString *const text = @"https://github.com/reesun1130";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"QRCode Example";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 扫描、读取、生成二维码

- (IBAction)scanoAction {
    __weak ViewController *weakSelf = self;
    
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString) {
        kTipsAlert(@"%@",qrString);
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

- (IBAction)readAction:(id)sender {
    ReadQRCodeViewController *vcRead = [[ReadQRCodeViewController alloc] initWithNibName:@"ReadQRCodeViewController" bundle:nil];
    [self.navigationController pushViewController:vcRead animated:YES];
}

- (IBAction)generateAction:(id)sender {
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
    CGSize size = CGSizeMake(80, 80);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    if (codeImage) {
        self.imageView.image = codeImage;
    }
    else {
        kTipsAlert(@"字符串不合法");
    }
}

@end
