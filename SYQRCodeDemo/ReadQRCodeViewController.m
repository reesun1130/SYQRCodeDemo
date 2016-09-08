//
//  ReadQRCodeViewController.m
//  SYQRCodeDemo
//
//  Created by sunyang on 16/8/27.
//  Copyright © 2016年 SY. All rights reserved.
//

#import "ReadQRCodeViewController.h"
#import <ZXingObjC/ZXingObjC.h>
#import "SYQRCodeOverlayView.h"
#import "SYQRCodeUtility.h"

@interface ReadQRCodeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labDescribe;

@end

@implementation ReadQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)readAction:(id)sender {
    [self openImagePicker];
}

- (void)openImagePicker {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

#pragma mark -UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *loadImage= [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString *des = @"";
    
    if (kIOS8_OR_LATER) {
        des = [SYQRCodeUtility readQRCodeImage:loadImage];
    }
    else {
        CGImageRef imageToDecode = loadImage.CGImage;
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        
        if (result.text.length > 0) {
            des = [des stringByAppendingString:result.text];
        }
    }
    
    if (des.length > 0) {
        self.labDescribe.text = [NSString stringWithFormat:@"二维码内容：%@",des];
        NSLog(@"二维码内容==%@",des);
    }
    else {
        self.labDescribe.text = @"解析失败";
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
