//
//  ViewController.m
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-6.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "ViewController.h"
#import "SYQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.saomiaoBtn.layer.borderColor = [UIColor greenColor].CGColor;
    self.saomiaoBtn.layer.borderWidth = 1.5;
    // Do any additional setup after loading the view, typically from a nib.
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
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        self.saomiaoLabel.text = @"fail~";
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
        self.saomiaoLabel.text = @"cancle~";
    };
    [self presentViewController:qrcodevc animated:YES completion:nil];
}

@end
