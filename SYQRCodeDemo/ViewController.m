//
//  ViewController.m
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-6.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#define kTipsAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]


#import "ViewController.h"
#import "SYQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.saomiaoBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.saomiaoBtn.layer.borderWidth = 1.5;
    self.title = @"Example";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//打开摄像头并扫描
- (IBAction)saomiaoAction:(id)sender
{
    //扫描二维码
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        self.saomiaoLabel.text = qrString;
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        kTipsAlert(@"Failed");
        [self.navigationController popViewControllerAnimated:YES];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        kTipsAlert(@"Cancle");
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:qrcodevc animated:YES];
}

@end
